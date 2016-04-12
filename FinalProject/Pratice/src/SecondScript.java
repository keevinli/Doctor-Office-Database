import java.sql.*;
import java.util.*;

import javax.swing.*;
import javax.swing.table.DefaultTableModel;
import javax.swing.table.TableColumn;

public class SecondScript {
    public static void main(String[] args) {
        Vector columnNames = new Vector();
        Vector data = new Vector();
        JPanel panel = new JPanel();   //
        try {
        	String url = "jdbc:sqlserver://localhost\\SQLEXPRESS:1433;databaseName=DoctorOffice;integratedSecurity=true";
      	  	Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
      	  	Connection conn = DriverManager.getConnection(url);
            String sql = "SELECT PatientID, DoctorID FROM VisitRecord WHERE VisitDate = '01/01/2001'";
            Statement statement = conn.createStatement();
            ResultSet resultSet = statement.executeQuery(sql);
            ResultSetMetaData metaData = resultSet.getMetaData();
            int columns = metaData.getColumnCount();
            for (int i = 1; i <= columns; i++) {
                columnNames.addElement(metaData.getColumnName(i));
            }
            
            
            while (resultSet.next()) {
                Vector row = new Vector(columns);
                for (int i = 1; i <= columns; i++) {
                    row.addElement(resultSet.getObject(i));
                }
                data.addElement(row);
            }
           resultSet.close();
            statement.close();
        } catch (Exception e) {
            System.out.println(e);
        }
        JTable table = new JTable(data, columnNames);
        TableColumn column;
        for (int i = 0; i < table.getColumnCount(); i++) {
            column = table.getColumnModel().getColumn(i);
            column.setMaxWidth(250);
        }
        JScrollPane scrollPane = new JScrollPane(table);        
        panel.add(scrollPane);               
        JFrame frame = new JFrame();
        frame.add(panel);         //adding panel to the frame
        frame.setSize(600, 400); //setting frame size
        frame.setVisible(true);  //setting visibility true  
    }
}
