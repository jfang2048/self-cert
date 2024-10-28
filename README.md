# Step
1. First, you need to create a self-signed CA (Certificate Authority) certificate; if you already have a genuine one, please disregard this step.
2. Create a self-signed certificate based on the CA certificate.
3. You need to install the CA certificate on your computer to access HTTPS websites using the self-signed certificate. I have only provided instructions for a Debian-based system; other distributions may vary, so please conduct your own search for specific instructions.
4. Additionally, you will need to import the CA certificate into your web browser, such as Firefox or Chrome.
     eg.Firefox : [Settings] > [Privacy & Security] > [View Certificates] > [Import] >

# Tips
It is advisable to review my script and make any necessary changes according to your own requirements before running it. I will not be responsible for any issues that arise. The above scripts are compiled from various sources found on the internet.
