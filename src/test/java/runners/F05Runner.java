package runners;

import com.intuit.karate.junit5.Karate;

public class F05Runner {
    @Karate.Test
    Karate testAll() {
        return Karate.run("classpath:F05/features");
    }
}
