package ru.itpark;

import java.sql.*;

public class Main {
    public static void main(String[] args) {
        try {
            Connection connection =
                    DriverManager.getConnection(
                            "jdbc:sqlite:data.sqlite3"
                    );

            Statement statement =
                    connection.createStatement();

            // executeQuery - достаёт данные (select)
            // executeUpdate - update/insert/delete
            // execute - делает всё остальное (ну и предыдущие 2 тоже может)
            ResultSet resultSet
                    = statement.executeQuery(
                            "SELECT id, name FROM managers"
            );

            // resultSet.first();
            while (resultSet.next()) { // идём вперёд
                // передвигает курсор на следующую позицию
                // next() = false, если дальше некуда идти

                // лучше не использовать resultSet.getInt(1); // 0 - не валидный индекс
                int id = resultSet.getInt("id");
                String name = resultSet.getString("name");

                System.out.println(name);
            }

            // Три домашки
            // SQL
            // 28-30 видео: -> heroku
            // push github -> Travis CI -> heroku
            // git'ом

            // 28 декабря,

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
