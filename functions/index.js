const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendAlertNotification = onDocumentCreated("alerts/{alertId}", async (event) => {
    if (!event.data) return;

    const alertData = event.data.data();
    if (!alertData) return;

    const recipientFcmToken = alertData.recipientToken;
    const title = alertData.title || "New Alert";
    const message = alertData.message || "You have a new message.";

    if (!recipientFcmToken) {
        console.log("No recipient FCM token provided in document.");
        return;
    }
p

    try {
        const response = await admin.messaging().send(payload);
        console.log("Successfully sent notification:", response);
    } catch (error) {
        console.error("Error sending notification:", error);
    }
});