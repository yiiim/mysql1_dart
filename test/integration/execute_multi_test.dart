library sqljocky.test.blob_test;

import 'package:sqljocky5/sqljocky.dart';
import 'package:test/test.dart';

import '../test_infrastructure.dart';

void main() {
  initializeTest("stream", "create table stream (id integer, name text)",
      "insert into stream (id, name) values (1, 'A'), (2, 'B'), (3, 'C')");

  test('store data', () async {
    var query = await pool.prepare('select * from stream where id = ?');
    var values = await query.executeMulti([
      [1],
      [2],
      [3]
    ]);
    expect(values, hasLength(3));

    var resultList = await values[0].toList();
    expect(resultList[0][0], equals(1));
    expect(resultList[0][1].toString(), equals('A'));

    resultList = await values[1].toList();
    expect(resultList[0][0], equals(2));
    expect(resultList[0][1].toString(), equals('B'));

    resultList = await values[2].toList();
    expect(resultList[0][0], equals(3));
    expect(resultList[0][1].toString(), equals('C'));
  }, skip: "Not ported");

  test('issue 43', () async {
    await conn.transaction((context) async {
      await context.query("SELECT * FROM stream");
      context.rollback();
    });
  });

  test('transaction rollback', () async {
    var count = await conn.query("SELECT COUNT(*) FROM stream");
    expect(count.first.first, 3);

    await conn.transaction((context) async {
      await context.query("insert into stream (id, name) values (1, 'A'), (2, 'B'), (3, 'C')");
      context.rollback();
    });

    count = await conn.query("SELECT COUNT(*) FROM stream");
    expect(count.first.first, 3);
  });


  test('transaction commit', () async {
    var count = await conn.query("SELECT COUNT(*) FROM stream");
    expect(count.first.first, 3);

    await conn.transaction((context) async {
      await context.query("insert into stream (id, name) values (1, 'A'), (2, 'B'), (3, 'C')");
    });

    count = await conn.query("SELECT COUNT(*) FROM stream");
    expect(count.first.first, 6);
  });


}
