import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp()

const db = admin.firestore();
const fcm = admin.messaging();
export const sendToDevice = functions.firestore
    .document('usernames/{userId}/follower/{followerId}')
    .onCreate(async snapshot => {
        
        const follower = snapshot.data();
        const querySnapshot = await db.collection('usernames').doc(follower.following).collection('tokens').get();
        const saveData = await db.collection('usernames').doc(follower.following).collection('notifications').add({
            'title': `${follower.follower}`,
            'body': `${follower.follower} has started following you`,
            'notificationFor': `${follower.following}`,
            'sendBy': `${follower.followerUid}`,
            'time': `${follower.time}`,
        });
        const tokens = querySnapshot.docs.map(snap => snap.id);
        console.log(`tokens ${tokens}`);
        const payLoad: admin.messaging.MessagingPayload = {
            notification: {
                title: `${follower.follower}`,
                body: `${follower.follower} has started following you`,
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
            }
        };
        console.log(`payload ${payLoad}`);
        return fcm.sendToDevice(tokens, payLoad, saveData);
    });

export const sendToDeviceLikes = functions.firestore
    .document('videos/{videoId}/likes/{likesId}')
    .onCreate(async snapshot => {
        
        const likes = snapshot.data();
        const querySnapshot = await db.collection('usernames').doc(likes.likedUserVideo).collection('tokens').get();
        const saveData = await db.collection('usernames').doc(likes.likedUserVideo).collection('notifications').add({
            'title': `${likes.likeUserName}`,
            'body': `${likes.likeUserName} has liked your post`,
            'notificationFor': `${likes.likedUserVideo}`,
            'sendBy': `${likes.likeUserUid}`,
            'time': `${likes.time}`,
        });
        const tokens = querySnapshot.docs.map(snap => snap.id);
        console.log(`tokens ${tokens}`);
        const payLoad: admin.messaging.MessagingPayload = {
            notification: {
                title: `${likes.likeUserName}`,
                body: `${likes.likeUserName} has liked your post`,
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
            }
        };
        console.log(`payload ${payLoad}`);
        return fcm.sendToDevice(tokens, payLoad, saveData);
    });

export const sendToDeviceComments = functions.firestore
    .document('videos/{videoId}/comments/{commentsId}')
    .onCreate(async snapshot => {
        
        const comments = snapshot.data();
        const querySnapshot = await db.collection('usernames').doc(comments.videoUserUid).collection('tokens').get();
        const saveData = await db.collection('usernames').doc(comments.videoUserUid).collection('notifications').add({
            'title': `${comments.userName}`,
            'body': `${comments.userName} commented your video: ${comments.comment}`,
            'notificationFor': `${comments.videoUserUid}`,
            'sendBy': `${comments.userUid}`,
            'time': `${comments.time}`,
        });
        const tokens = querySnapshot.docs.map(snap => snap.id);
        console.log(`tokens ${tokens}`);
        const payLoad: admin.messaging.MessagingPayload = {
            notification: {
                title: `${comments.userName}`,
                body: `${comments.userName} commented your video: ${comments.comment}`,
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
            }
        };
        console.log(`payload ${payLoad}`);
        return fcm.sendToDevice(tokens, payLoad, saveData);
    });




// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
