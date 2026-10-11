# Lab_Thread_Counter — Static vs Non-Static Counter in Multithreading

**Name:** Ridhikanta Sarkar Sumit | **ID:** IT24045 | **Course:** SEPM-001

## 1. Files

- `Sumit_Thread.java` – typed version used for running
- `handwritten/` – photo/scan of the handwritten code
- `outputs/` – screenshots (`TC1.png` … `TC7.png`), `output.txt`, `results.csv`, `tables.md`
- `run_all.ps1` – runs all test cases (1 safe + 5 unsynchronized runs each)
- `show_case.ps1` – prints one test case (used for the screenshots)
- `make_tables.ps1` – builds the result tables from `results.csv`

## 2. How to run

```bash
javac Sumit_Thread.java
java Sumit_Thread 10 100000 true    # thread-safe (AtomicLong)
java Sumit_Thread 10 100000 false   # unsynchronized
```

## 3. Test inputs

| Test | Threads | Increments/thread | Expected |
| --- | --- | --- | --- |
| TC1 | 1 | 1,000 | 1,000 |
| TC2 | 2 | 10,000 | 20,000 |
| TC3 | 5 | 10,000 | 50,000 |
| TC4 | 10 | 50,000 | 500,000 |
| TC5 | 20 | 50,000 | 1,000,000 |
| TC6 | 50 | 50,000 | 2,500,000 |
| TC7 | 100 | 50,000 | 5,000,000 |

## 4. Output screenshots

![TC1](outputs/TC1.png)
![TC2](outputs/TC2.png)
![TC3](outputs/TC3.png)
![TC4](outputs/TC4.png)
![TC5](outputs/TC5.png)
![TC6](outputs/TC6.png)
![TC7](outputs/TC7.png)

## 5. Result analysis

<!-- Paste the contents of outputs/tables.md here -->

## 6. Observation & Conclusion

<!-- Write this from YOUR tables. Cover:
     - What the thread-safe runs showed (static vs non-static, difference).
     - What happened with 1 thread, and why.
     - How the average % changed as threads increased. Say honestly if it
       rose, fell, or did both, and give your actual numbers.
     - How much runs with the same thread count varied (give min and max).
     - Your explanation for the trend. If you did not measure the cause,
       say it is a likely explanation, not a proven one. -->

### Why this happens

`count++` on a regular `long` is three steps: read, add 1, write back. If two
threads read the same value before either writes, one increment is lost (a race
condition). `AtomicLong.incrementAndGet()` does the whole update as one
indivisible operation, so nothing is lost. The non-static counter belongs to a
single thread's object, so it is never contended.

### Conclusion

- `static` vs non-static describes ownership, not thread safety.
- A shared static counter needs synchronization or atomic operations.
- Lost updates appear with concurrency, but the percentage difference is not
  guaranteed to grow steadily with thread count.
- The thread-safe experiment is the control case: 0% difference.

## 7. Analysis questions (answers)

1. A static variable belongs to the class and has one copy shared by all objects. A non-static variable belongs to each object, which has its own copy.
2. There is only one copy of a static variable, stored with the class, so every thread reads and writes the same memory.
3. Each thread runs its own object, and each object has its own instance field that no other thread touches.
4. `start()` returns immediately. `join()` makes `main` wait until every thread finishes, so the totals are final when read.
5. `count++` is read, add, write. Two threads can read the same value and write back the same result, so one increment is lost.
6. No. Loss depends on scheduling, core count, and runtime behavior, so the trend is not guaranteed to be monotonic. (Support this with your own data.)
7. The OS and JVM schedule threads differently on each run, so the number of collisions differs.
8. `AtomicLong` performs each increment as a single atomic operation (compare-and-set), so no updates are lost.
9. Create one object and pass that same object to every `Thread`, so they share its instance counter. Make that counter an `AtomicLong` or protect it with `synchronized`.
