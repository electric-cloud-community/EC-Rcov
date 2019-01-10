@::gMatchers = (
    #invalid target
    {
        id =>        "load-fileError",
        pattern =>       q{no such file to load -- (.*) \(LoadError\)},
        action =>        q{&addSimpleError("load-fileError", "No such file to load $1");updateSummary();},
    },
    #ambiguous option
    {
        id =>        "ambiguous-option",
        pattern =>       q{ambiguous option: (.*) \(OptionParser::AmbiguousOption\)},
        action =>        q{&addSimpleError("ambiguous-option", "Ambiguous option found: $1");updateSummary();},
    },
    #file not found
    {
        id =>        "not-found-file",
        pattern =>       q{No file to analyze was found.},
        action =>        q{&addSimpleError("not-found-file", "No file to analyze was found.");updateSummary();},
    },
    #Couldn't load coverage data
    {
        id =>        "load-coverage",
        pattern =>        q{Couldn't load coverage data from (.*)},
        action =>         q{&addSimpleError("load-coverage", "Couldn't load coverage data from: $1");setProperty("outcome", "error" );updateSummary();},
    },
);

sub addSimpleError {
    my ($name, $customError) = @_;
    if(!defined $::gProperties{$name}){
        setProperty($name, $customError);
    }
}

sub incValueWithString($;$$) {
    my ($name, $patternString, $increment) = @_;

    $increment = 1 unless defined($increment);

    my $localString = (defined $::gProperties{$name}) ? $::gProperties{$name} :
                                                        $patternString;

    $localString =~ /([^\d]*)(\d+)(.*)/;
    my $leading = $1;
    my $numeric = $2;
    my $trailing = $3;
    
    $numeric += $increment;
    $localString = $leading . $numeric . $trailing;

    setProperty ($name, $localString);
}

sub updateSummary() {
    my $summary = (defined $::gProperties{"load-fileError"}) ? $::gProperties{"load-fileError"} . "\n" : "";
    $summary .= (defined $::gProperties{"ambiguous-option"}) ? $::gProperties{"ambiguous-option"} . "\n" : "";
    $summary .= (defined $::gProperties{"not-found-file"}) ? $::gProperties{"not-found-file"} . "\n" : "";
    $summary .= (defined $::gProperties{"load-coverage"}) ? $::gProperties{"load-coverage"} . "\n" : "";
   
    setProperty("summary", $summary);
}