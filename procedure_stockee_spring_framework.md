## Appeler procedure
## Utilisation de JdbcTemplate :
```
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class EmployeeRepository {

    private final JdbcTemplate jdbcTemplate;

    public EmployeeRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public void callStoredProcedure() {
        String procedureName = "nom_procedure";
        jdbcTemplate.execute("{CALL " + procedureName + "}");
    }
}

```

## procedure avec paramétre
### Utilisation de Spring Data JPA :
```
import org.springframework.data.jpa.repository.query.Procedure;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface EmployeeRepository extends CrudRepository<Employee, Long> {

    @Procedure(name = "nom_procedure")
    void callStoredProcedure();
}

```

### Utilisation de JdbcTemplate :
```
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class EmployeeRepository {

    private final JdbcTemplate jdbcTemplate;

    public EmployeeRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public void callStoredProcedure(String param1, int param2) {
        String procedureName = "nom_procedure";
        jdbcTemplate.update("{CALL " + procedureName + "(?, ?)}", param1, param2);
    }
}
```

### Utilisation de Spring Data JPA :
```
import org.springframework.data.jpa.repository.query.Procedure;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface EmployeeRepository extends CrudRepository<Employee, Long> {

    @Procedure(name = "nom_procedure")
    void callStoredProcedure(String param1, int param2);
}
```

## Appeler une vue 
### Utilisation de JdbcTemplate :
```
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class EmployeeRepository {

    private final JdbcTemplate jdbcTemplate;

    public EmployeeRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<Employee> getEmployeesFromView() {
        String sql = "SELECT * FROM nom_vue";
        return jdbcTemplate.query(sql, (resultSet, rowNum) -> {
            // Mapping des résultats de la vue à un objet Employee
            Employee employee = new Employee();
            employee.setId(resultSet.getLong("id"));
            employee.setName(resultSet.getString("name"));
            // ... autres attributs
            return employee;
        });
    }
}

```
### Utilisation de Spring Data JPA :
```
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface EmployeeRepository extends JpaRepository<Employee, Long> {

    @Query(value = "SELECT * FROM nom_vue", nativeQuery = true)
    List<Employee> getEmployeesFromView();
}
```
