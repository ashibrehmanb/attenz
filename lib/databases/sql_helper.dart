import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/utils/utils.dart';

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE items(
        rollno TEXT NOT NULL,
        regno TEXT PRIMARY KEY NOT NULL,
        name TEXT NOT NULL,
        address TEXT,
        guardian TEXT,
        phone TEXT,
        batch TEXT NOT NULL,
        UNIQUE (rollno, batch)
      )
      """);
    await database.execute("""CREATE TABLE batches(
        course TEXT NOT NULL,
        year TEXT NOT NULL,
        PRIMARY KEY (course, year)
      )
      """);
    await database.execute("""CREATE TABLE teachers(
        name TEXT NOT NULL,
        username TEXT PRIMARY KEY NOT NULL,
        password TEXT NOT NULL 
      )
      """);
    await database.execute("""CREATE TABLE attendance(
        attdate TEXT NOT NULL,
        regno TEXT NOT NULL,
        status TEXT,
        sem TEXT NOT NULL,
        markedby TEXT NOT NULL,
        PRIMARY KEY (attdate, regno),
        FOREIGN KEY (regno) REFERENCES items(regno)
      )
      """);
    await database.execute("""CREATE TABLE holidays(
        holidate TEXT PRIMARY KEY NOT NULL,
        desc TEXT NOT NULL,
        remarks TEXT
      )
      """);
  }
// id: the id of a item
// created_at: the time that the item was created. It will be automatically handled by SQLite

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'students.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  // Create new item (journal)
  static Future<void> createItem(String rollno, String regno, String name,
      String? address, String? guardian, String? phone, String batch) async {
    final db = await SQLHelper.db();

    final data = {
      'rollno': rollno,
      'regno': regno,
      'name': name,
      'address': address,
      'guardian': guardian,
      'phone': phone,
      'batch': batch,
    };
    await db.insert('items', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  // Read all items (journals)
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query('items', orderBy: "rollno");
  }

  //Read items based on batch
  static Future<List<Map<String, dynamic>>> getItemsonBatch(
      String batch) async {
    final db = await SQLHelper.db();
    return db.query('items',
        orderBy: "rollno", where: "batch = ?", whereArgs: [batch]);
  }

  // Read a single item by id
  // The app doesn't use this method but I put here in case of future purposes
  // static Future<List<Map<String, dynamic>>> getItem(int id) async {
  //   final db = await SQLHelper.db();
  //   return db.query('items', where: "id = ?", whereArgs: [id], limit: 1);
  // }

  // Update an item by id
  static Future<int> updateItem(String id, String rollno, String regno,
      String name, String? address, String? guardian, String? phone) async {
    final db = await SQLHelper.db();

    final data = {
      'rollno': rollno,
      'regno': regno,
      'name': name,
      'address': address,
      'guardian': guardian,
      'phone': phone,
    };

    final result =
        await db.update('items', data, where: "regno = ?", whereArgs: [id]);
    await db.update('attendance', {'regno': regno},
        where: "regno = ?", whereArgs: [id]);
    return result;
  }

  // Delete
  static Future<void> deleteItem(String regno) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("items", where: "regno = ?", whereArgs: [regno]);
      await db.delete("attendance", where: "regno = ?", whereArgs: [regno]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  //Batches DataTable

  //Create new batch
  static Future<void> createBatch(String course, String year) async {
    final db = await SQLHelper.db();
    final data = {
      'course': course,
      'year': year,
    };
    await db.insert('batches', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

// Read all batches
  static Future<List<Map<String, dynamic>>> getBatches() async {
    final db = await SQLHelper.db();
    return db.query('batches', orderBy: "year");
  }

  // Delete
  static Future<void> deleteBatch(String course, String year) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("batches",
          where: "course = ? and year = ?", whereArgs: [course, year]);
    } catch (err) {
      debugPrint("Something went wrong when deleting a batch: $err");
    }
  }

  //Teachers DataTable
  static Future<void> createTeacher(
      String name, String username, String password) async {
    final db = await SQLHelper.db();

    final data = {'name': name, 'username': username, 'password': password};
    await db.insert('teachers', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  // Read all batches
  static Future<List<Map<String, dynamic>>> getTeachers() async {
    final db = await SQLHelper.db();
    return db.query('teachers', orderBy: "name");
  }

  // Delete
  static Future<void> deleteTeacher(String username) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("teachers", where: "username = ?", whereArgs: [username]);
    } catch (err) {
      debugPrint("Something went wrong when deleting a teacher: $err");
    }
  }

  //Attendance DataTable
  static Future<void> createAttendance(String attdate, String regno,
      String status, String sem, String markedby) async {
    final db = await SQLHelper.db();

    final data = {
      'attdate': attdate,
      'regno': regno,
      'status': status,
      'sem': sem,
      'markedby': markedby
    };
    await db.insert('attendance', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  // Read all batches
  static Future<List<Map<String, dynamic>>> getAttendance(
      String batch, String sem, String? attdate) async {
    final db = await SQLHelper.db();
    return (attdate == null)
        ? await db.rawQuery(
            'SELECT * FROM attendance,items WHERE attendance.regno=items.regno and items.batch = ? and attendance.sem = ?',
            [
                batch,
                sem
              ])
        : await db.rawQuery(
            'SELECT * FROM attendance,items WHERE attendance.regno=items.regno and items.batch = ? and attendance.sem = ? and attendance.attdate = ?',
            [batch, sem, attdate]);
  }

  static Future<List<Map<String, dynamic>>> getBatchesFromAttendance() async {
    final db = await SQLHelper.db();
    // return db.query('attendance',
    //     distinct: true, columns: ['batch'], orderBy: "attdate");
    return db.rawQuery(
        'SELECT DISTINCT items.batch FROM attendance,items WHERE attendance.regno=items.regno ORDER BY attendance.attdate');
  }

  static Future<List<Map<String, dynamic>>> getSemFromAttendance(
      String batch) async {
    final db = await SQLHelper.db();
    // return db.query('attendance',
    //     distinct: true,
    //     columns: ['sem'],
    //     orderBy: "sem",
    //     where: "batch = ?",
    //     whereArgs: [batch]);
    return db.rawQuery(
        'SELECT DISTINCT attendance.sem FROM attendance,items WHERE attendance.regno=items.regno and items.batch = ?',
        [batch]);
  }

  static Future<List<Map<String, dynamic>>> getDatesFromAttendance(
      String batch, String? sem) async {
    final db = await SQLHelper.db();
    // return db.query('attendance',
    //     distinct: true,
    //     columns: ['attdate'],
    //     orderBy: "attdate",
    //     where: (sem == null) ? "batch = ?" : "batch = ? and sem = ?",
    //     whereArgs: (sem == null) ? [batch] : [batch, sem]);
    return (sem == null)
        ? db.rawQuery(
            'SELECT DISTINCT attendance.attdate FROM attendance,items WHERE attendance.regno=items.regno and items.batch = ?',
            [
                batch
              ])
        : db.rawQuery(
            'SELECT DISTINCT attendance.attdate FROM attendance,items WHERE attendance.regno=items.regno and items.batch = ? and attendance.sem = ?',
            [batch, sem]);
  }

  // Delete
  static Future<void> deleteAttendance(String date, String batch) async {
    final db = await SQLHelper.db();
    try {
      // await db.delete("attendance",
      //     where: "attdate = ? and batch = ?", whereArgs: [date, batch]);
      await db.rawDelete(
          'DELETE FROM attendance WHERE attendance.regno IN (SELECT attendance.regno FROM attendance,items WHERE attendance.regno=items.regno and attendance.attdate = ? and items.batch = ?)',
          [date, batch]);
    } catch (err) {
      debugPrint("Something went wrong when deleting attendance: $err");
    }
  }

  static Future<int> getCountPresent(String regno, String sem) async {
    //database connection
    String status = 'Present';
    final db = await SQLHelper.db();
    var x = await db.rawQuery(
        'SELECT COUNT (*) FROM attendance WHERE regno=? and sem=? and status=?',
        [regno, sem, status]);
    int? count = firstIntValue(x);
    return (count == null) ? 0 : count;
  }

  static Future<List<Map<String, dynamic>>> getWeightCount(
      String status, String batch, String sem, String? date) async {
    final db = await SQLHelper.db();
    return await db.rawQuery(
        'SELECT * FROM attendance,items WHERE attendance.regno=items.regno and items.batch = ? and attendance.status = ? and attendance.sem = ? and attendance.attdate = ?',
        [batch, status, sem, date]);
  }

  //holidays connection table

  // Create new item (journal)
  static Future<void> createHolidays(
      String holidate, String desc, String? remarks) async {
    final db = await SQLHelper.db();

    final data = {
      'holidate': holidate,
      'desc': desc,
      'remarks': remarks,
    };
    await db.insert('holidays', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  // Read all items (journals)
  static Future<List<Map<String, dynamic>>> getHolidays() async {
    final db = await SQLHelper.db();
    return db.query('holidays', orderBy: "holidate");
  }

  // Update an item by id
  static Future<int> updateHoliday(
      String id, String holidate, String desc, String? remarks) async {
    final db = await SQLHelper.db();

    final data = {
      'holidate': holidate,
      'desc': desc,
      'remarks': remarks,
    };

    final result = await db
        .update('holidays', data, where: "holidate = ?", whereArgs: [id]);
    return result;
  }

  // Delete
  static Future<void> deleteHoliday(String holidate) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("holidays", where: "holidate = ?", whereArgs: [holidate]);
    } catch (err) {
      debugPrint("Something went wrong when deleting a holiday: $err");
    }
  }
}
