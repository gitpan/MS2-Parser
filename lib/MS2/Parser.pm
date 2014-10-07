package MS2::Parser;

use v5.12;
use strict;
use warnings;
use Moose;
use namespace::autoclean;
use MS2::Header;
use MS2::Scan;

=head1 NAME

MS2::Parser - A parser for MS2 files, commonly used in mass spectrometry based proteomics projects.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use MS2::Parser;

    my $ms = MS2::Parser->new();

    $ms->parse("file.ms2");

    # accessing header information
    print $ms->header->ScanType;


=cut

=head1 DESCRIPTION
This is a Moose based parser for the MS2 file format. The MS2 file format is used to 
record MS/MS spectra. A full description of the MS2 file format may be found in: 
McDonald,W.H. et al. MS1, MS2, and SQT-three unified, compact, and easily parsed 
file formats for the storage of shotgun proteomic spectra and identifications. 
Rapid Commun. Mass Spectrom. 18, 2162-2168 (2004).
=cut

=head2 Methods

=head3 parse
This is the main function to call. The parse method recieves a path to the ms2 file
and returns a Moose object containing two attributes; A MS2::Header (header info) 
and a list of MS2::Scan (scan info).

    $ms->parse("file.ms2");

=head2 Attributes

=head2 header

    # accessing header information
    print $ms->header->ScanType;


This is a representation of how MS2 data is organized inside the object. The MS2 object 
has a MS2::Header object with the following structure:

    internals: {
        AcquisitionMethod   "Data-Dependent",
        Comments            "RawXtract modified by Tao Xu, 2007",
        CreationDate        "4/13/2009 6:45:15 PM",
        DataType            "Centroid",
        Extractor           "RAWXtract",
        ExtractorOptions    "MS2",
        ExtractorVersion    "1.9.9.2",
        FirstScan           1,
        InstrumentType      "ITMS",
        IsolationWindow     undef,
        LastScan            33000,
        ScanType            "MS2"
    }


=head2 scan

    # accessing header information
    print $ms->scan->[0]->Mass;

    # copiyng the arraylist reference to an array.
    my @array = $ms->scanlist;


The MS2 object has a MS2::Scan object list with the following structure:

        internals: {
            ActivationType     "CID",
            Charge             7,
            Data               {
                308.8282   15.6,
                362.2597   27.8,
                390.5037   12.6,
                547.0424   16.2,
                563.5495   28.7,
                661.8907   15.6
            },
            FirstScan          000006,
            InstrumentType     "ITMS",
            IonInjectionTime   25.000,
            Mass               2833.0688,
            PrecursorFile      "Pfu_Orbit_041209_05.ms1",
            PrecursorInt       214647.2,
            PrecursorMZ        405.58749,
            PrecursorScan      1,
            RetTime            0.03,
            SecondScan         000006
        }
    }

The Data attribute is represented as a Hash reference.


=cut

has 'header' => (
    is  =>  'rw',
    isa =>  'MS2::Header',
    );

has 'scanlist' => (
    is  =>  'rw',
    isa =>  'ArrayRef',
    );


sub parse {
    my $self = shift;
    my $path = shift;

    open (my $file, '<', $path) or die "[Error]: Could not opne file!\n";

    my $header  = MS2::Header->new();
    my $scan;
    my @scanlist;

    my $flag = 0;

    while ( my $line = <$file> ) {
        chomp $line;

        if ( $line =~ m/^H/ ) {

            $flag = 1;

        } elsif ( $line =~ m/^S/ ) {

            if ($scan) {
                push(@scanlist, $scan);
            }

            $flag = 2;
            $scan = MS2::Scan->new();

        } elsif ( $line =~ m/^[IZ]/ ) {

            $flag = 2;

        } elsif ( $line =~ m/^\d/ ) {

            $flag = 3;

        }
        
        if ( eof ) {

            push(@scanlist, $scan);
        }

        if ( $flag == 1 ) {
            
            $header->parse($line);

        } elsif ( $flag == 2 ) {

            $scan->parse($line);

        } elsif ( $flag == 3 ) {

            $scan->parse($line);
        }
    }

    $self->header($header);
    $self->scanlist(\@scanlist);
}

=head1 AUTHOR

Felipe da Veiga Leprevost, C<< <leprevost at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-ms2-parser at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=MS2-Parser>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc MS2::Parser


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=MS2-Parser>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/MS2-Parser>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/MS2-Parser>

=item * Search CPAN

L<http://search.cpan.org/dist/MS2-Parser/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2014 Felipe da Veiga Leprevost.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of MS2::Parser
