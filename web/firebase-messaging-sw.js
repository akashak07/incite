importScripts("https://www.gstatic.com/firebasejs/9.12.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/9.12.1/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyCQw148jvkCeortzo5oiWM8RSiWPWlbAJY",
      authDomain: "incite-90ab3.firebaseapp.com",
      projectId: "incite-90ab3",
      storageBucket: "incite-90ab3.appspot.com",
      messagingSenderId: "399479013826",
      appId: "1:399479013826:web:aa83319a61649efabb165b",
      measurementId: "G-LV4LHJC5Y0"
});
// Necessary to receive background messages:
const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((m) => {
  console.log("onBackgroundMessage", m);
});