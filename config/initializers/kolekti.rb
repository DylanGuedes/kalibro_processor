require 'kolekti'
require 'kolekti_analizo'
require 'kolekti/cc_phpmd'
require 'kolekti/metricfu'

Kolekti.register_collector(Kolekti::Analizo::Collector)
Kolekti.register_collector(Kolekti::CcPhpMd::Collector)
Kolekti.register_collector(Kolekti::Metricfu::Collector)
