function [ metric ] = calculateMetric( data,  mode, options)
%CALCULATEMETRIC calculates a metric over a data window to determine
%if this window contains an event that differs from normal data.
%Takes as input:
%DATA: the window of EEG data points (timepoints x channels)
%MODE: an integer indicating how to compute the metric
%OPTIONS: additional optional argument defining parameters of the
%computation of the metric. Format depends on the mode used.
%Returns:
%METRIC: a value of the metric for each channel, if metric computation does
%not keep channel information, it should return a value for each channel 
%anyway

if mode == 1 % coastline
 


end

