package zwlab;

import com.intuit.karate.core.MockServer;

/**
 * Stands up an actor interceptor that WAITS for a client, so you can test that client's
 * conformance. It stores nothing - it intercepts each request and either forwards it to the real
 * FHIR server's $validate (submissions) or gates/forwards it (queries).
 *
 *   mvn test-compile exec:java -Dexec.args="ehr 8080"   # EHR: order placer + results consumer
 *   mvn test-compile exec:java -Dexec.args="lab 8081"   # Lab: order consumer + report submitter
 *   ... -Dtarget=http://173.212.195.88/fhir             # real server used for $validate / forwarding
 *
 * Then point the client under test at http://localhost:<port>.
 * (The SHR / repository actor is tested by the normal `mvn test` suite, not an interceptor.)
 */
public class LabMockServer {

    public static void main(String[] args) {
        String actor = args.length > 0 ? args[0] : "ehr";
        int port = args.length > 1 ? Integer.parseInt(args[1]) : 8080;
        String feature = "classpath:zwlab/mock/" + actor + ".feature";
        MockServer server = MockServer.feature(feature).http(port).build();
        System.out.println(actor.toUpperCase() + " interceptor listening on http://localhost:" + port
                + "  (feature: " + feature + ")");
        server.waitSync();
    }
}
