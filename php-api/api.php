<?php
header('Content-Type: application/json');

$dsn = 'pgsql:host=postgres-1;port=5432;dbname=postgresdb';
$username = 'admin';
$password = 'admin';

try {
    $pdo = new PDO($dsn, $username, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
} catch (PDOException $e) {
    echo json_encode(['error' => 'Database connection failed: ' . $e->getMessage()]);
    exit;
}

function jsonResponse($data) {
    echo json_encode($data, JSON_PRETTY_PRINT);
    exit;
}

$method = $_SERVER['REQUEST_METHOD'];
$input = json_decode(file_get_contents('php://input'), true);

switch ($method) {
    case 'GET':
        if (isset($_GET['firstname'])) {
            $stmt = $pdo->prepare('SELECT * FROM customers WHERE firstname = :firstname');
            $stmt->execute(['firstname' => $_GET['firstname']]);
            jsonResponse($stmt->fetchAll(PDO::FETCH_ASSOC));
        } else {
            $stmt = $pdo->query('SELECT * FROM customers');
            jsonResponse($stmt->fetchAll(PDO::FETCH_ASSOC));
        }
        break;

    case 'POST':
        if (!isset($input['firstname'])) {
            jsonResponse(['error' => 'Missing firstname field']);
        }
        $stmt = $pdo->prepare('INSERT INTO customers (firstname, date_created) VALUES (:firstname, NOW())');
        $stmt->execute(['firstname' => $input['firstname']]);
        jsonResponse(['status' => 'Customer added']);
        break;

    case 'PUT':
        if (!isset($input['customer_id']) || !isset($input['firstname'])) {
            jsonResponse(['error' => 'Missing customer_id or firstname field']);
        }
        $stmt = $pdo->prepare('UPDATE customers SET firstname = :firstname WHERE customer_id = :customer_id');
        $stmt->execute(['customer_id' => $input['customer_id'], 'firstname' => $input['firstname']]);
        jsonResponse(['status' => 'Customer updated']);
        break;

    case 'DELETE':
        if (!isset($input['customer_id'])) {
            jsonResponse(['error' => 'Missing customer_id field']);
        }
        $stmt = $pdo->prepare('DELETE FROM customers WHERE customer_id = :customer_id');
        $stmt->execute(['customer_id' => $input['customer_id']]);
        jsonResponse(['status' => 'Customer deleted']);
        break;

    default:
        jsonResponse(['error' => 'Invalid request method']);
        break;
}
?>
