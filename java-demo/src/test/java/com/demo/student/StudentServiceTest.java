package com.demo.student;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class StudentServiceTest {

    @Test
    void createUpdateAndDeleteShouldWork() {
        StudentService service = new StudentService();

        service.createStudent(new Student(1, "Alice", 19, "alice@example.com"));
        service.createStudent(new Student(2, "Bob", 22, "bob@example.com"));

        assertEquals(2, service.getAllStudents().size());

        boolean updated = service.updateStudent(2, "Bobby", 23, "bobby@example.com");
        assertTrue(updated);
        assertEquals("Bobby", service.getById(2).orElseThrow().getName());

        boolean deleted = service.deleteStudent(1);
        assertTrue(deleted);
        assertEquals(1, service.getAllStudents().size());

        boolean deletedMissing = service.deleteStudent(99);
        assertFalse(deletedMissing);
    }
}

