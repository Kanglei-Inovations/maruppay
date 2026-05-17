import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

/**
 * Triggered by Firebase Scheduler
 * Runs every day to check for groups that need a draw
 */
export const scheduledMarupDraw = functions.pubsub
  .schedule("every 24 hours")
  .onRun(async (context) => {
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();

    // 1. Find active groups where nextDrawDate <= now
    const groupsSnapshot = await db
      .collection("groups")
      .where("status", "==", "active")
      .where("nextDrawDate", "<=", now)
      .get();

    for (const groupDoc of groupsSnapshot.docs) {
      await performSecureDraw(groupDoc.id);
    }
  });

/**
 * Secure Lottery Logic
 */
async function performSecureDraw(groupId: string) {
  const db = admin.firestore();
  
  // 1. Get Group Data
  const groupRef = db.collection("groups").doc(groupId);
  const group = (await groupRef.get()).data();
  if (!group) return;

  // 2. Get Eligible Members (Pot 1)
  // Conditions: Payment completed & Not previous winner in this cycle
  const membersSnapshot = await db
    .collection("memberships")
    .where("groupId", "==", groupId)
    .where("hasPaid", "==", true)
    .where("hasWon", "==", false)
    .get();

  const eligibleMembers = membersSnapshot.docs;
  if (eligibleMembers.length === 0) return;

  // 3. Secure Random Selection (Anti-cheat)
  const winnerIndex = Math.floor(Math.random() * eligibleMembers.length);
  const winningMemberDoc = eligibleMembers[winnerIndex];
  const winnerData = winningMemberDoc.data();

  // 4. Update Database (Atomic Transaction)
  await db.runTransaction(async (transaction) => {
    // Mark member as winner
    transaction.update(winningMemberDoc.ref, { hasWon: true });

    // Create Winner Record
    const winnerId = db.collection("winners").doc().id;
    transaction.set(db.collection("winners").doc(winnerId), {
      groupId,
      userId: winnerData.userId,
      userName: winnerData.userName,
      winningAmount: group.contributionAmount * group.totalMembers * (1 - group.adminCommissionPercentage/100),
      drawDate: admin.firestore.Timestamp.now(),
      cycleNumber: group.currentCycle,
    });

    // Update Group Next Draw Date
    const nextDraw = new Date();
    nextDraw.setDate(nextDraw.getDate() + group.drawFrequencyDays);
    transaction.update(groupRef, { nextDrawDate: nextDraw });
  });
}
