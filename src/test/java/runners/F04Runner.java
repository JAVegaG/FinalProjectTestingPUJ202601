package runners;

import com.intuit.karate.junit5.Karate;

public class F04Runner {
    @Karate.Test
    Karate testAll() {
        return Karate.run("classpath:F04/features");
    }
}
