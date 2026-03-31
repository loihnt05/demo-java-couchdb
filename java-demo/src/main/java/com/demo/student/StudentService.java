package com.demo.student;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

public class StudentService {
    private final List<Student> students = new ArrayList<>();

    public Student createStudent(Student student) {
        boolean exists = students.stream().anyMatch(s -> s.getId() == student.getId());
        if (exists) {
            throw new IllegalArgumentException("Student id already exists: " + student.getId());
        }
        students.add(student);
        return student;
    }

    public List<Student> getAllStudents() {
        return new ArrayList<>(students);
    }

    public Optional<Student> getById(int id) {
        return students.stream().filter(s -> s.getId() == id).findFirst();
    }

    public boolean updateStudent(int id, String newName, int newAge, String newEmail) {
        Optional<Student> target = getById(id);
        if (target.isEmpty()) {
            return false;
        }

        Student student = target.get();
        student.setName(newName);
        student.setAge(newAge);
        student.setEmail(newEmail);
        return true;
    }

    public boolean deleteStudent(int id) {
        return students.removeIf(s -> s.getId() == id);
    }

    public List<Student> filterByMinAge(int minAge) {
        return students.stream()
                .filter(student -> student.getAge() >= minAge)
                .collect(Collectors.toList());
    }

    public List<Student> sortByName() {
        return students.stream()
                .sorted(Comparator.comparing(Student::getName))
                .collect(Collectors.toList());
    }

    public List<String> mapToUppercaseNames() {
        return students.stream()
                .map(student -> student.getName().toUpperCase())
                .collect(Collectors.toList());
    }
}

