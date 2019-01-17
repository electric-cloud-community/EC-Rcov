# -------------------------------------------------------------------------
# Includes
# -------------------------------------------------------------------------
use ElectricCommander;
use warnings;
use strict;
$|=1;

# -------------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------------
use constant {
	SUCCESS => 0,
	ERROR   => 1,
	
	PLUGIN_NAME => 'EC-Rcov',
	EXECUTABLE => 'rcov',
    DEFAULT_FOLDER => "coverage",
	DEFAULT_RESULT_FILENAME => 'index.html',
	DEFAULT_FILENAME => 'coverage.info',
	TRACE_RSPEC => 'rspec',
	TRACE_TEST_CASES => 'testcases',
	
};

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
my $ec = ElectricCommander->new();
$ec->abortOnError(0);
$::gOutputPath                = ($ec->getProperty( "outputpath" ))->findvalue('//value')->string_value;
$::gWorkingDir                = ($ec->getProperty( "workingdir" ))->findvalue('//value')->string_value;
$::gAdditionalRcovCommands    = ($ec->getProperty( "additionalrcovcommands" ))->findvalue('//value')->string_value;
$::gAdditionalTargetCommands  = ($ec->getProperty( "additionaltargetcommands" ))->findvalue('//value')->string_value;
$::gSave                      = ($ec->getProperty( "save" ))->findvalue('//value')->string_value;
$::gTextDetailedReport        = ($ec->getProperty( "detailedreport" ))->findvalue('//value')->string_value;
$::gTextSummaryConsole        = ($ec->getProperty( "summaryreport" ))->findvalue('//value')->string_value;
$::gTextCoverageConsole       = ($ec->getProperty( "coveragereport" ))->findvalue('//value')->string_value;
$::gTextCountsConsole         = ($ec->getProperty( "countreport" ))->findvalue('//value')->string_value;
$::gCompare                   = ($ec->getProperty( "compare" ))->findvalue('//value')->string_value;
$::gCompareFile               = ($ec->getProperty( "coveragefiletocompare" ))->findvalue('//value')->string_value;
$::gMinimumThreshold          = ($ec->getProperty( "minimumthreshold" ))->findvalue('//value')->string_value;
$::gColorBlindSafe            = ($ec->getProperty( "colorblindsafe" ))->findvalue('//value')->string_value;
$::gAnnotate                  = ($ec->getProperty( "annotate" ))->findvalue('//value')->string_value;
$::gTargets                   = ($ec->getProperty( "targets" ))->findvalue('//value')->string_value;


# -------------------------------------------------------------------------
# Main functions
# -------------------------------------------------------------------------


########################################################################
# main - contains the whole process to be done by the plugin, it builds 
#        the command line, sets the properties and the working directory
#
# Arguments:
#   none
#
# Returns:
#   none
#
########################################################################
sub main() {
    
    # create args arrays
    my @args = ();
    
    #properties' map
    my %props;
    
    #setting the executables
    push(@args, EXECUTABLE);
    
    if($::gOutputPath && $::gOutputPath ne ''){
        push(@args, '--output ' . qq{"$::gOutputPath"});
    }
    
    
    if($::gColorBlindSafe && $::gColorBlindSafe ne ''){
        push(@args, '--no-color');
    }
    
    if($::gAnnotate && $::gAnnotate ne ''){
        push(@args, '--annotate');
    }
    
    if($::gTextDetailedReport && $::gTextDetailedReport ne ''){
        push(@args, '--text-report');
    }
    
    if($::gTextSummaryConsole && $::gTextSummaryConsole ne ''){
        push(@args, '--text-summary');
    }
    
    if($::gTextCoverageConsole && $::gTextCoverageConsole ne ''){
        push(@args, '--text-coverage');
    }
    
    if($::gTextCountsConsole && $::gTextCountsConsole ne ''){
        push(@args, '--text-counts');
    }
    
    if($::gTextCountsConsole eq '' &&
             $::gTextCoverageConsole eq '' &&
             $::gTextSummaryConsole eq '' &&
             $::gTextDetailedReport eq ''){
         
         push(@args, '--html');
         
    }    
    
    if($::gCompare && $::gCompare ne ''){
     
       if($::gCompareFile && $::gCompareFile ne ''){
          push(@args, '--text-coverage-diff ' . $::gCompareFile);
       }else{
          push(@args, '--text-coverage-diff');
       }
     
    }
    
    if($::gSave && $::gSave ne ''){
        push(@args, '--save ' . DEFAULT_FILENAME);
    }
    
    if($::gMinimumThreshold && $::gMinimumThreshold ne ''){
        push(@args, '--threshold ' . $::gMinimumThreshold);
    }    
    
    #additional commands for each program    
    if($::gAdditionalRcovCommands  && $::gAdditionalRcovCommands  ne '') {
        foreach my $command (split(' +', $::gAdditionalRcovCommands)) {
            push(@args, $command);
        }
    }
    
    if($::gTargets && $::gTargets ne ''){
        push(@args, $::gTargets);
    }

    #additional commands for each program    
    if($::gAdditionalTargetCommands  && $::gAdditionalTargetCommands  ne '') {
        foreach my $command (split(' +', $::gAdditionalTargetCommands)) {
            push(@args, $command);
        }
    }

    #register the report generated by the program
    registerReports();

    #generate the command to execute in console
    $props{'commandLine'} = createCommandLine(\@args);
    
    #set the working directory
    $props{'workingdir'} = $::gWorkingDir;
    
    #set the properties into the Electric Commander
    setProperties(\%props);
    
}

########################################################################
# createCommandLine - creates the command line for the invocation
# of the program to be executed.
#
# Arguments:
#   -arr: array containing the command name and the arguments entered by 
#         the user in the UI
#
# Returns:
#   -the command line to be executed by the plugin
#
########################################################################
sub createCommandLine($) {

    my ($arr) = @_;

    my $commandName = @$arr[0];

    my $command = $commandName;

    shift(@$arr);

    foreach my $elem (@$arr) {
        $command .= " $elem";
    }

    return $command;
    
}

########################################################################
# setProperties - set a group of properties into the Electric Commander
#
# Arguments:
#   -propHash: hash containing the ID and the value of the properties 
#              to be written into the Electric Commander
#
# Returns:
#   none
#
########################################################################
sub setProperties($) {

    my ($propHash) = @_;

    # get an EC object
    my $ec = new ElectricCommander();
    $ec->abortOnError(0);

    foreach my $key (keys % $propHash) {
        my $val = $propHash->{$key};
        $ec->setProperty("/myCall/$key", $val);
    }
}

########################################################################
# registerReports - creates a link for registering the generated report
# in the job step detail
#
# Arguments:
#   none
#
# Returns:
#   none
#
########################################################################
sub registerReports {
    if($::gOutputPath eq "" && $::gWorkingDir eq ""){
        my $ec = ElectricCommander->new();
        $ec->abortOnError(0);
        $ec->setProperty("/myJob/artifactsDirectory", '');   
        $ec->setProperty("/myJob/report-urls/@PLUGIN_KEY@ Report","jobSteps/$[jobStepId]/" . DEFAULT_FOLDER . '/'. DEFAULT_RESULT_FILENAME);
    }
}

main();

1;
