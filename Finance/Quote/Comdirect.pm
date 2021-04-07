package Finance::Quote::Comdirect;

use strict;
use LWP::UserAgent;
use HTTP::Request::Common;

sub methods { return ( comdirect => \&funds ); }
sub labels { return ( comdirect => [qw/exchange name date isodate price method/]); }

sub funds {
    my $quoter = shift;
    my @stocks = @_;

    my %info;

    my $ua = $quoter->user_agent;

    foreach my $stock (@stocks) {
      my $response = $ua->request(GET "https://www.comdirect.de/inf/fonds/${stock}");
      unless ($response->is_success) {
        $info{$stock,"success"} = 0;
        $info{$stock,"errormsg"} = "HTTP failure";
        return wantarray() ? %info : \%info;
      }
      my $found = 0;
      foreach my $line ($response->content) {
        if ($line =~ /(<div class="realtime-indicator"><span |<span class="realtime-indicator--value)[^>]*>([^<]*)<\/span>.*EUR<\/span>/) {
          $found = 1;
          my $price = $2 =~ s/,/./r;
          $info{$stock, "exchange"} = "Comdirect";
          $info{$stock, "name"} = $stock;
          $info{$stock, "symbol"} = $stock;
          $info{$stock, "price"} = $price;
          $info{$stock, "method"} = "comdirect";
          $info{$stock, "currency"} = "EUR";
          $info{$stock, "success"} = 1;
        }
      }
      if (!$found) {
        $info{$stock, "success"} = 0;
        $info{$stock, "errormsg"} = "No Data Found";
      }
    }
    
    return wantarray() ? %info : \%info;
}

1;
