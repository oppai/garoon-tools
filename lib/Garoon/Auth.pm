package Garoon::Auth;
use 5.008005;
use strict;
use warnings;

use HTTP::Request;
use LWP::UserAgent;
use YAML::Syck;

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

sub login {
    my ($self,$domain,$id,$pass) = @_;

    my $xml = $self->soap_request_xml($id,$pass);
    my $request = HTTP::Request->new(
        POST => "https://$domain.cybozu.com/g/util_api/util/api.csp",
        [
            'User-Agent' => 'User-Agent: NuSOAP/0.7.3 (1.114)',
            'Content-Type' => 'text/xml; charset=UTF-8',
            SOAPAction => '"UtilLogin"',
            'Content-Length' => length $xml,
        ],
        $xml,
    );

    my $ua = LWP::UserAgent->new;
    $self->{_domain} = $domain;
    $self->{_response} = $ua->request($request);
    $self->{_cookies} = $self->{_response}->{_headers}->{'set-cookie'};

    $self->save;

    return $self->is_login;
};

sub is_login {
    my ($self) = @_;
    return defined $self->{_response} and $self->{_response}->{_msg} eq 'OK';
};

sub save {
    my ($self) = @_;
    return unless $self->is_login;

    my $data = {};
    $data->{'domain'} = $self->{_domain};
    $data->{'cookies'} = $self->{'_cookies'};
    return YAML::Syck::DumpFile('config/user.yaml',$data);
};

sub load {
    my ($self) = @_;
    my $data = YAML::Syck::LoadFile('config/user.yaml') or die( "$!" );
    $self->{_cookies} = $data->{cookies};
    $self->{_domain} = $data->{domain};

    return $self->{_cookies} and $self->{_domain};
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

