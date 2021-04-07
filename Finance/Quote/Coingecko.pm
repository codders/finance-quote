package Finance::Quote::Coingecko;

use strict;
use LWP::UserAgent;
use HTTP::Request::Common;
use JSON qw(decode_json);

sub methods { return ( coingecko => \&funds ); }
sub labels { return ( coingecko  => [qw/exchange name date isodate price method/]); }

sub funds {
    my $quoter = shift;
    my @stocks = @_;

    my %info;

    my $ua = $quoter->user_agent;

    foreach my $stock (@stocks) {
      my $response = $ua->request(GET "https://api.coingecko.com/api/v3/simple/price?ids=${stock}&vs_currencies=eur");
      unless ($response->is_success) {
        $info{$stock,"success"} = 0;
        $info{$stock,"errormsg"} = "HTTP failure";
        return wantarray() ? %info : \%info;
      }
      my $found = 0;
      my $response_json = decode_json($response->content);
      my $price = $response_json->{$stock}{"eur"};
      $info{$stock, "exchange"} = "Coingecko";
      $info{$stock, "name"} = $stock;
      $info{$stock, "symbol"} = $stock;
      $info{$stock, "price"} = $price;
      $info{$stock, "method"} = "coingecko";
      $info{$stock, "currency"} = "EUR";
      $info{$stock, "success"} = 1;
    }
    
    return wantarray() ? %info : \%info;
}

1;
