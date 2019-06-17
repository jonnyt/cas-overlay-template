import java.util.*;
import org.apereo.cas.authentication.exceptions.*;
import javax.security.auth.login.*;

def Exception run(final Object... args) {
    def principal = args[0];
    def logger = args[1];
    if (principal.id == 'jonathont') {
        return new AccountDisabledException();
    }
    return null;
}
