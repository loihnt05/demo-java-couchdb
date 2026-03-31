package com.demo.student;

import java.util.List;

public class Main {
    public static void main(String[] args) {
        StudentService service = new StudentService();

        seedData(service);

        System.out.println("=== Java Student CRUD + Stream API Demo ===");
        printStudents("Initial students", service.getAllStudents());

        service.createStudent(new Student(5, "Eva", 20, "eva@example.com"));
        printStudents("After CREATE (add Eva)", service.getAllStudents());

        boolean updated = service.updateStudent(2, "Bob", 23, "bob23@example.com");
        System.out.println("UPDATE id=2 result: " + updated);
        printStudents("After UPDATE", service.getAllStudents());

        boolean deleted = service.deleteStudent(3);
        System.out.println("DELETE id=3 result: " + deleted);
        printStudents("After DELETE", service.getAllStudents());

        showStreamDemo(service);
        showLoopComparison(service);
    }

    private static void seedData(StudentService service) {
        service.createStudent(new Student(1, "Alice", 19, "alice@example.com"));
        service.createStudent(new Student(2, "Bob", 22, "bob@example.com"));
        service.createStudent(new Student(3, "Charlie", 18, "charlie@example.com"));
        service.createStudent(new Student(4, "Diana", 24, "diana@example.com"));
    }

    private static void showStreamDemo(StudentService service) {
        System.out.println("\n--- Stream API demo ---");

        List<Student> adults = service.filterByMinAge(21);
        printStudents("filter(age >= 21)", adults);

        List<Student> sorted = service.sortByName();
        printStudents("sorted by name", sorted);

        System.out.println("map(name -> UPPERCASE) + forEach:");
        service.mapToUppercaseNames().forEach(System.out::println);
    }

    private static void showLoopComparison(StudentService service) {
        System.out.println("\n--- Traditional loop comparison (age >= 21) ---");
        for (Student student : service.getAllStudents()) {
            if (student.getAge() >= 21) {
                System.out.println(student);
            }
        }
    }

    private static void printStudents(String title, List<Student> students) {
        System.out.println("\n" + title + ":");
        if (students.isEmpty()) {
            System.out.println("(no students)");
            return;
        }
        students.forEach(System.out::println);
    }
}

