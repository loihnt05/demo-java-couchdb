# Java Student CRUD + Stream API Demo

This demo is a simple Java console application for classroom presentation.

It shows:
- OOP with a `Student` class (encapsulation + validation)
- CRUD operations in `StudentService` using in-memory `ArrayList`
- Stream API operations: `filter`, `map`, `sorted`, `forEach`
- A quick comparison with a traditional loop

## Project Structure

- `src/main/java/com/demo/student/Student.java`
- `src/main/java/com/demo/student/StudentService.java`
- `src/main/java/com/demo/student/Main.java`
- `src/test/java/com/demo/student/StudentServiceTest.java`

## Run

If Maven is available:

```bash
cd /home/loiancut/workspace/demo-jc/java-demo
mvn -q test
mvn -q exec:java
```

If Maven is not available, use `javac` directly:

```bash
cd /home/loiancut/workspace/demo-jc/java-demo
mkdir -p out
javac -d out src/main/java/com/demo/student/*.java
java -cp out com.demo.student.Main
```

