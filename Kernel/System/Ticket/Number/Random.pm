# --
# Copyright (C) 2012-2018 Znuny GmbH, http://znuny.com/
# Copyright (C) 2001-2018 OTRS AG, http://otrs.com/
# --
# $origin: otrs - 60b6e4d9389021b705eb237fc147cae305b23852 - Kernel/System/Ticket/Number/Random.pm
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

#
# Port of OTRS 5 random number generator for OTRS 6
# --

package Kernel::System::Ticket::Number::Random;

use strict;
use warnings;

use parent qw(Kernel::System::Ticket::NumberBase);

our @ObjectDependencies = (
    'Kernel::Config',
);

sub IsDateBased {
    return 0;
}

sub TicketNumberBuild {
    my ( $Self, $Offset ) = @_;

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    $Offset ||= 0;

    my $BaseCounter = 1;
    if ( $Self->TicketNumberCounterIsEmpty() ) {
        $BaseCounter = $Self->InitialCounterOffsetCalculate();
    }

    my $Counter = $Self->TicketNumberCounterAdd(
        Offset => $BaseCounter + $Offset,
    );

    return if !$Counter;

    my $Count = int rand 9999999999;
    $Count    = sprintf "%.*u", 10, $Count;

    my $SystemID     = $ConfigObject->Get('SystemID');
    my $TicketNumber = $SystemID . $Count;

    return $TicketNumber;
}

sub GetTNByString {
    my ( $Self, $String ) = @_;

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    if ( !$String ) {
        return;
    }

    my $CheckSystemID = $ConfigObject->Get('Ticket::NumberGenerator::CheckSystemID');
    my $SystemID      = '';

    if ($CheckSystemID) {
        $SystemID = $ConfigObject->Get('SystemID');
    }

    my $TicketHook        = $ConfigObject->Get('Ticket::Hook');
    my $TicketHookDivider = $ConfigObject->Get('Ticket::HookDivider');

    # check current setting
    if ( $String =~ /\Q$TicketHook$TicketHookDivider\E($SystemID\d{2,20})/i ) {
        return $1;
    }

    # check default setting
    if ( $String =~ /\Q$TicketHook\E:\s{0,2}($SystemID\d{2,20})/i ) {
        return $1;
    }

    return;
}

1;
