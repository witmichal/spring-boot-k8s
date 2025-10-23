from multiprocessing.dummy import Pool
import sys
import requests

if __name__ == '__main__':
    schema_and_host = sys.argv[1]
    number_of_threads = 50

    pool = Pool(number_of_threads)
    futures = []

    for _ in range(number_of_threads ):
        futures.append(pool.apply_async(requests.get, [f'{schema_and_host}/cpu-load/times/2000/length/10000']))


    for future in futures:
        print(future.get()) # wait until the request is finished

