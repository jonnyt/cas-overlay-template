import org.apereo.cas.interrupt.InterruptResponse;

def run(final Object... args) {
    def uid = args[0];
    def attributes = args[1];
    def service = args[2];
    def logger = args[3];

    def block = true;
    def ssoEnabled = true;
    logger.info("Processing " + uid + " for auth block");
    if(uid == "jonathont") {
        return new InterruptResponse("Message", [link1:"google.com", link2:"yahoo.com"], block, ssoEnabled);
    }
}
