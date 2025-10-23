from multiprocessing.dummy import Pool
import time
import requests

def get_cpu():
    for i in range(60):
        cpu_response = requests.get('http://localhost:8080/actuator/metrics/system.cpu.usage')
        print("CPU: " + str(cpu_response.json()['measurements'][0]['value']))
        time.sleep(1)

if __name__ == '__main__':
    number_of_threads = 50

    pool = Pool(number_of_threads)
    futures = []

    futures.append(pool.apply_async(get_cpu))

    for _ in range(number_of_threads - 1):
        futures.append(pool.apply_async(requests.get, ['http://localhost:8080/cpu-load/1000']))


    for future in futures:
        print(future.get()) # wait until the request is finished

