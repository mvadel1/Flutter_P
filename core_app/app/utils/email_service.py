import os
import smtplib
import ssl
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

def send_reset_email(to_email, reset_link):

    EMAIL_ADDRESS = os.environ.get('SMTP_EMAIL')
    EMAIL_PASSWORD = os.environ.get('SMTP_PASSWORD')
    SMTP_HOST = os.environ.get('SMTP_HOST', 'smtp.gmail.com')
    SMTP_PORT = int(os.environ.get('SMTP_PORT', 465))

    subject = "Reset your password"
    text = f"Click the following link to reset your password:\n\n{reset_link}"
    html = f"""
    <p>Click the following link to reset your password:</p>
    <p><a href="{reset_link}">{reset_link}</a></p>
    """

    message = MIMEMultipart("alternative")
    message["Subject"] = subject
    message["From"] = EMAIL_ADDRESS
    message["To"] = to_email

    part1 = MIMEText(text, "plain")
    part2 = MIMEText(html, "html")
    message.attach(part1)
    message.attach(part2)

    context = ssl.create_default_context()

    try:
        with smtplib.SMTP_SSL(SMTP_HOST, SMTP_PORT, context=context) as server:
            server.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
            server.sendmail(EMAIL_ADDRESS, to_email, message.as_string())
        return True
    except Exception as e:
        print("Error sending email:", e)
        return False
