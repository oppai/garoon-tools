package Garoon::Tools;
use 5.008005;
use strict;
use warnings;

use HTTP::Request;
use LWP::UserAgent;

$ENV{'PERL_LWP_SSL_VERIFY_HOSTNAME'} = 0;

our $VERSION = "0.01";

sub new {
    my $self = {};
    bless $self;
    return $self;
};

sub soap_request_xml {
    my ($self,$id,$pass) = @_;

    return <<"EOS";
<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://www.w3.org/2003/05/soap-envelope"
 xmlns:xsd="http://www.w3.org/2001/XMLSchema"
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"
 xmlns:util_api_services="http://wsdl.cybozu.co.jp/util_api/2008">
  <SOAP-ENV:Header>
    <Action SOAP-ENV:mustUnderstand="1"
     xmlns="http://schemas.xmlsoap.org/ws/2003/03/addressing">UtilLogin</Action>
    <Security xmlns:wsu="http://schemas.xmlsoap.org/ws/2002/07/utility"
     SOAP-ENV:mustUnderstand="1"
     xmlns="http://schemas.xmlsoap.org/ws/2002/12/secext">
    </Security>
    <Timestamp SOAP-ENV:mustUnderstand="1" Id="id"
     xmlns="http://schemas.xmlsoap.org/ws/2002/07/utility">
      <Created>2037-08-12T14:45:00Z</Created>
      <Expires>2037-08-12T14:45:00Z</Expires>
    </Timestamp>
    <Locale>jp</Locale>
  </SOAP-ENV:Header>
  <SOAP-ENV:Body>
    <UtilLogin>
      <parameters>
        <login_name xmlns="">$id</login_name>
        <password xmlns="">$pass</password>
      </parameters>
    </UtilLogin>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>
EOS
};

sub auth {
    my ($self,$url,$id,$pass) = @_;

    my $xml = $self->soap_request_xml($id,$pass);
    my $request = HTTP::Request->new(
        POST => "https://$url.cybozu.com/g/util_api/util/api.csp",
        [
            'User-Agent' => 'User-Agent: NuSOAP/0.7.3 (1.114)',
            'Content-Type' => 'text/xml; charset=UTF-8',
            SOAPAction => '"UtilLogin"',
            'Content-Length' => length $xml,
        ],
        $xml,
    );

    my $ua = LWP::UserAgent->new;
    $self->{_response} = $ua->request($request);
    $self->{_cookies} = $self->{_response}->{_headers}->{'set-cookie'};

    return $self->is_login;
};

sub is_login {
    my ($self) = @_;
    return $self->{_response}->{_msg} eq 'OK';
};

1;
__END__

=encoding utf-8

=head1 NAME

Garoon::Tools - It's new $module

=head1 SYNOPSIS

    use Garoon::Tools;

=head1 DESCRIPTION

Garoon::Tools is ...

=head1 LICENSE

Copyright (C) kodam.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

kodam E<lt>hotsoup.h@gmail.comE<gt>

=cut

