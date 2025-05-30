

INSERT INTO customers VALUES
(1, 'John', 'Doe', 'john.doe@example.com', '555-1234'),
(2, 'Jane', 'Smith', 'jane.smith@example.com', '555-5678');

INSERT INTO menu_items VALUES
(1, 'Burger', 'Main', 8.99),
(2, 'Fries', 'Side', 3.49),
(3, 'Soda', 'Drink', 1.99);

INSERT INTO orders VALUES
(1, 1, '2025-05-01', 15.47),
(2, 2, '2025-05-02', 10.48);

INSERT INTO order_items VALUES
(1, 1, 1, 1),
(2, 1, 2, 1),
(3, 1, 3, 1),
(4, 2, 1, 1),
(5, 2, 3, 1);
