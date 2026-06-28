INSERT INTO dim_vendor (vendor_id, vendor_name)
VALUES
    (1, 'Creative Mobile Technologies'),
    (2, 'Curb Mobility'),
    (6, 'Myle Technologies'),
    (7, 'Helix')
ON CONFLICT (vendor_id) DO NOTHING;

INSERT INTO dim_payment_type (payment_type_id, payment_type_name)
VALUES
    (1, 'Credit card'),
    (2, 'Cash'),
    (3, 'No charge'),
    (4, 'Dispute'),
    (5, 'Unknown'),
    (6, 'Voided trip')
ON CONFLICT (payment_type_id) DO NOTHING;