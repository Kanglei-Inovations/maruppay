import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

const delay = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

/**
 * PRODUCTION-LEVEL LIVE DRAW ORCHESTRATION
 * This function manages the real-time synchronization between Admin and Member apps.
 */
export const executeLiveDraw = functions.https.onCall(async (data, context) => {
  const drawId = data.drawId;
  const drawRef = db.collection("draws").doc(drawId);
  const drawDoc = await drawRef.get();

  if (!drawDoc.exists) throw new functions.https.HttpsError("not-found", "Draw not found.");
  
  const drawData = drawDoc.data();
  const groupId = drawData?.groupId;

  // 1. Fetch eligible PAID members
  const membersSnapshot = await db.collection("groups").doc(groupId).collection("group_members")
    .where("status", "==", "active")
    .where("paymentStatus", "==", "paid")
    .get();
  
  if (membersSnapshot.empty) {
    await drawRef.update({ status: "completed", notes: "No paid members." });
    return { success: false, message: "No eligible members." };
  }

  const members = membersSnapshot.docs.map(doc => ({ uid: doc.id, ...doc.data() }));

  // --- SEQUENCE START ---
  
  // PHASE: STARTING
  await drawRef.update({ status: "starting", serverTime: admin.firestore.FieldValue.serverTimestamp() });
  await delay(4000);

  // PHASE: POT SHAKING (Visual cue for both apps)
  await drawRef.update({ status: "pot_shaking" });
  await delay(5000);

  // PHASE: SELECTING NAME (Pick a name from Pot 1)
  const winnerIndex = Math.floor(Math.random() * members.length);
  const winner = members[winnerIndex];
  const userDoc = await db.collection("users").doc(winner.uid).get();
  const winnerName = userDoc.data()?.fullName || "Member";

  await drawRef.update({ 
    status: "selecting_name", 
    currentName: winnerName, // Use currentName for real-time display
    winnerName: winnerName, 
    winnerId: winner.uid 
  });
  await delay(6000);

  // PHASE: SELECTING GEM (Pick from Pot 2 - Two Pot Logic)
  // In a Marup, usually there's a specific 'Winner Gem' (e.g. Ruby)
  const selectedGem = "assets/ruby.png"; // Use the asset path directly for the UI

  await drawRef.update({ 
    status: "selecting_gem", 
    currentGem: selectedGem // Use currentGem to match DrawModel
  });
  await delay(6000);

  // PHASE: WINNER REVEAL (The sync point for fireworks)
  await drawRef.update({ status: "winner_reveal" });
  
  // Wallet Credit
  await db.collection("wallets").doc(winner.uid).set({
    balance: admin.firestore.FieldValue.increment(drawData?.poolAmount || 0),
    updatedAt: admin.firestore.FieldValue.serverTimestamp()
  }, { merge: true });

  // Transaction Record
  await db.collection("transactions").add({
    userId: winner.uid,
    amount: drawData?.poolAmount || 0,
    type: "winning",
    status: "success",
    description: `Marup Won: ${drawData?.poolAmount}`,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    drawId: drawId
  });

  await delay(10000);

  // PHASE: COMPLETED
  await drawRef.update({ status: "completed" });

  return { success: true, winnerName: winnerName };
});
