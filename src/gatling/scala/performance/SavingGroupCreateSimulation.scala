package performance

import com.intuit.karate.gatling.PreDef._
import io.gatling.core.Predef._

import scala.concurrent.duration._

class SavingGroupCreateSimulation extends Simulation {

  private val protocol = karateProtocol()

  private val createSavingGroup = scenario("saving-group-create-poc")
    .exec(karateFeature("classpath:performance/saving_group_create_perf.feature"))

  setUp(
    createSavingGroup.inject(
      rampUsers(5).during(10.seconds),
      constantUsersPerSec(1).during(20.seconds)
    )
  ).protocols(protocol)
    .assertions(
      global.successfulRequests.percent.gte(95),
      global.responseTime.percentile3.lt(3000)
    )
}
