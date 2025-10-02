package test.kube

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class KubeApplication

fun main(args: Array<String>) {
	runApplication<KubeApplication>(*args)
}
