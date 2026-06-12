package zwlab;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import org.junit.jupiter.api.Test;

import java.nio.file.Files;
import java.nio.file.Path;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Single entry point so every feature runs in one go.
 *
 *   mvn test
 *       -> runs all features under zwlab/ (submit/poll orders + results)
 *
 *   mvn test -Dkarate.features=classpath:zwlab/submit-orders.feature
 *       -> run a subset (comma-separate for several)
 *
 * Reports:
 *   target/karate-reports/karate-summary.html   (Karate's own report, with step detail)
 *   Allure (prettier):  mvn allure:serve   (or  mvn allure:report)
 */
class ZwLabTest {

    @Test
    void testAll() {
        // Default order: submit orders -> poll orders -> submit results -> poll results.
        String features = System.getProperty("karate.features", String.join(",",
                "classpath:zwlab/submit-orders.feature",
                "classpath:zwlab/poll-orders.feature",
                "classpath:zwlab/submit-results.feature",
                "classpath:zwlab/poll-results.feature"));
        Results results = Runner.path(features.split(","))
                .outputJunitXml(true)
                .parallel(1);
        writeAllureMetadata(results.getReportDir());
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }

    /** Drop the report-name, environment and category files Allure reads from the results dir. */
    private static void writeAllureMetadata(String reportDir) {
        try {
            Path dir = Path.of(reportDir);

            // Report name + build line. (Note: allure-maven generates its own executor from the
            // pom; this file is used when generating with the Allure CLI instead.)
            Files.writeString(dir.resolve("executor.json"), """
                {
                  "name": "Karate",
                  "type": "junit",
                  "buildName": "ZW Lab IG - API tests",
                  "reportName": "ZW Lab IG - Karate API tests"
                }
                """);

            // Environment widget.
            Files.writeString(dir.resolve("environment.properties"), String.join("\n",
                    "Base.URL=" + baseUrl(),
                    "FHIR.Version=R4 (4.0.1)",
                    "Order.Profile=http://mohcc.gov.zw/fhir/lab/StructureDefinition/zw-lab-service-request",
                    "Result.Profile=http://mohcc.gov.zw/fhir/lab/StructureDefinition/zw-lab-diagnostic-report"
            ) + "\n");

            // Categories tab - buckets for failures, if any.
            Files.writeString(dir.resolve("categories.json"), """
                [
                  { "name": "Profile validation failures ($validate)", "matchedStatuses": ["failed", "broken"], "messageRegex": ".*(validate|profile|OperationOutcome|issue).*" },
                  { "name": "Server rejections", "matchedStatuses": ["failed", "broken"] }
                ]
                """);
        } catch (Exception e) {
            System.err.println("Could not write Allure metadata: " + e);
        }
    }

    /** Mirror of the baseUrl resolution in karate-config.js, for the environment widget. */
    private static String baseUrl() {
        String url = System.getProperty("baseUrl");
        if (url != null) {
            return url;
        }
        String env = System.getProperty("karate.env", "zw");
        return switch (env) {
            case "local" -> "http://localhost:8080/fhir";
            case "hapi" -> "https://hapi.fhir.org/baseR4";
            default -> "http://173.212.195.88/fhir";
        };
    }
}
