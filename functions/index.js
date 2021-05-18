
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const nodemailer = require('nodemailer');



const gmailEmail = functions.config().nodemailer.email;
const gmailPassword = functions.config().nodemailer.password;
const mailTransport = nodemailer.createTransport({
  service: 'gmail',
   auth: {
          user: functions.config().nodemailer.email,
          pass: functions.config().nodemailer.password
      },
});

// Your company name to include in the emails
const APP_NAME = 'VisAb, Visit Abyssinia';

exports.sendVerificationCode = functions.firestore
    .document('guides/{id}')
    .onCreate((snap, context) => {
      // Get an object representing the document
      // e.g. {'name': 'Marie', 'age': 66}
      const newGuide = snap.data();

      // access a particular field as you would any JS property
      const name = newGuide.name;
      const email = newGuide.email;
      const id = newGuide.id;

      return sendVerificationCode(name, email, id);
    });

async function sendVerificationCode(name, email,id){
        const mailOptions = {
            from: `${APP_NAME} <noreply@firebase.com>`,
            to: email,
          };
          // The user subscribed to the newsletter.
          mailOptions.subject = `Welcome to ${APP_NAME}!`;
            mailOptions.text = `Hey ${displayName || ''}!
            Welcome to ${APP_NAME}. We hope you will enjoy our service.
            In case you want to edit your profile use this code: ${guide_id} to login into the app as a tour guide`;
          await mailTransport.sendMail(mailOptions);
          functions.logger.log('New welcome email sent to:', email);
          return null;
}

