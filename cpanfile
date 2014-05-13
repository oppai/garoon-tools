requires 'perl', '5.008001';

on 'getcookie' => sub {
    requires 'Term::ReadKey', '2.32';
};

on 'test' => sub {
    requires 'Test::More', '0.98';
};

