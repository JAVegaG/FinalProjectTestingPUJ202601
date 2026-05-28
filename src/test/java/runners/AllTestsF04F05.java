package runners;

import com.intuit.karate.junit5.Karate;

public class AllTestsF04F05 {
    @Karate.Test
    Karate testAll() {
        return Karate.run("classpath:F04/features", "classpath:F05/features");
    }
}
