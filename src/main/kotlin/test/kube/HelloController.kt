package test.kube

import io.github.oshai.kotlinlogging.KotlinLogging
import org.springframework.beans.factory.annotation.Value
import org.springframework.boot.context.event.ApplicationReadyEvent
import org.springframework.context.event.EventListener
import org.springframework.http.HttpStatus
import org.springframework.http.HttpStatus.BAD_REQUEST
import org.springframework.http.HttpStatus.OK
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestHeader
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.client.RestClient
import java.security.Key
import java.time.Duration
import java.time.LocalDateTime
import java.time.LocalDateTime.now
import java.util.UUID.randomUUID
import javax.crypto.Cipher
import javax.crypto.spec.SecretKeySpec

private val logger = KotlinLogging.logger {}

@RestController
class HelloController {

    private lateinit var appStartedAt: LocalDateTime

    @EventListener(ApplicationReadyEvent::class)
    fun startApp() {
        appStartedAt = now()
    }

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

    // App is considered HEALTHY 20 seconds after startup
    @GetMapping("/health")
    fun health(@RequestHeader("Probe", required = false) probe: String?): ResponseEntity<String> {
        val response = if (passedSinceStartup(seconds = 1)) code(OK) else code(BAD_REQUEST)
        logger.info {
            "/health [since app started: ${fromStartup().seconds}s] [$probe] -> ${response.statusCode.value()}"
        }
        return response
    }

    // App is considered READY 35 seconds after startup
    @GetMapping("/ready")
    fun ready(): ResponseEntity<String> {
        val response = if (passedSinceStartup(seconds = 2)) code(OK) else code(BAD_REQUEST)
        logger.info {
            "/ready [since app started: ${fromStartup().seconds}s] -> ${response.statusCode.value()}"
        }
        return response
    }

    @GetMapping("/cpu-load/times/{times}/length/{length}")
    fun triggerCpu(
        @PathVariable("times") times: Int,
        @PathVariable("length") length: Int,
    ): ResponseEntity<String> {
        encrypt(times, length)
        return code(OK)
    }

    private fun code(code: HttpStatus) = ResponseEntity<String>(code)

    private fun passedSinceStartup(seconds: Int): Boolean {
        return fromStartup() > Duration.ofSeconds(seconds.toLong())
    }

    private fun fromStartup() = Duration.between(appStartedAt, now())

    private fun encrypt(times: Int, length: Int) {
        val cipher = Cipher.getInstance("AES")
            .also {
                it.init(
                    Cipher.ENCRYPT_MODE,
                    SecretKeySpec("Bar12345Bar12345".toByteArray(), "AES")
                )
            }
        val uuidLength = 36
        repeat(times) {
            val toEncrypt = generateSequence { randomUUID().toString() }
                .take(length / uuidLength)
                .joinToString()
                .toByteArray()
            cipher.update(toEncrypt)
        }
    }
}
