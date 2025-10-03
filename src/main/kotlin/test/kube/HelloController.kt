package test.kube

import org.springframework.beans.factory.annotation.Value
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.client.RestClient

@RestController
class HelloController {

    @Value("\${spring.application.name}")
    lateinit var appName: String

    @Value("\${http.client.host}")
    lateinit var host: String

    @Value("\${database.password}")
    lateinit var dbPass: String

    @GetMapping("/")
    fun index(): String {
        return "Greetings from $appName | DB_PASSWORD=$dbPass"
    }

    @GetMapping("/call-service")
    fun callService(): String? {
        return RestClient
            .create()
            .get()
            .uri("http://$host/")
            .retrieve()
            .body(String::class.java)
    }
}
