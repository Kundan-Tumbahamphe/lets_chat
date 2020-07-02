const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.addChatMessage = functions.firestore
  .document('/chats/{chatId}/messages/{messageId}')
  .onCreate(async (snapshot, context) => {
    const messageData = snapshot.data();

    const chatId = context.params.chatId;
    const chatDocRef = admin.firestore().collection('chats').doc(chatId);
    const chatDoc = await chatDocRef.get();
    const chatData = chatDoc.data();

    if (chatDoc.exists) {
      const readStatus = chatData.readStatus;
      for (let userId in readStatus) {
        if (
          readStatus.hasOwnProperty(userId) &&
          userId !== messageData.senderId
        ) {
          readStatus[userId] = false;
        }
      }

      chatDocRef.update({
        recentMessage: messageData.text,
        recentSender: messageData.senderId,
        recentTimestamp: messageData.timestamp,
        readStatus: readStatus,
      });

      const memberInfo = chatData.memberInfo;
      const senderId = messageData.senderId;
      let notifText = memberInfo[senderId].name;
      if (messageData.text !== null) {
        notifText += `: ${messageData.text}`;
      } else {
        notifText += ' sent an image';
      }

      const payload = {
        notification: {
          title: chatData['name'],
          body: notifText,
        },
      };

      const options = {
        priority: 'high',
        timeToLive: 60 * 60 * 24,
      };

      for (const userId in memberInfo) {
        if (userId !== senderId) {
          const token = memberInfo[userId].token;

          if (token !== '') {
            admin.messaging().sendToDevice(token, payload, options);
          }
        }
      }
    }
  });

exports.onUpdateUser = functions.firestore
  .document('/users/{userId}')
  .onUpdate(async (snapshot, context) => {
    const userId = context.params.userId;
    const userData = snapshot.after.data();
    const newToken = userData.token;

    return admin
      .firestore()
      .collection('chats')
      .where('memberIds', 'array-contains', userId)
      .orderBy('recentTimestamp', 'desc')
      .get()
      .then((snapshots) => {
        return snapshots.forEach((chatDoc) => {
          const chatData = chatDoc.data();
          const memberInfo = chatData.memberInfo;
          memberInfo[userId].token = newToken;
          chatDoc.ref.update({ memberInfo: memberInfo });
        });
      });
  });
