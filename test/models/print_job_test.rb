# frozen_string_literal: true

require 'test_helper'

class PrintJobTest < ActiveSupport::TestCase
  include WithStubbedPmb

  setup do
    @printer = create :printer
  end

  test 'valid jobs can print' do
    PMB::TestSuiteStubs.post('/v1/print_jobs', print_post(@printer.name, @printer.label_template.external_id)) do |_env|
      [200, { content_type: 'application/json' }, print_job_response(@printer.name, @printer.label_template.external_id)]
    end
    pj = PrintJob.new(printables: [{ label: { test_atrr: 'test', barcode: '12345' } }], printer: @printer.name)
    assert pj.print, 'Valid job saved with false'
  end

  test 'invalid jobs return errors' do
    pj = PrintJob.new(printables: [{ label: { test_atrr: 'test', barcode: '12345' } }], printer: 'non_existant_printer')
    assert_equal false, pj.print, 'Invalid job saved with true'
    assert_includes pj.errors.full_messages, 'Printer has not been registered'
  end

  test 'handle invalid reponses from PMB' do
    PMB::TestSuiteStubs.post('/v1/print_jobs', print_post(@printer.name, @printer.label_template.external_id)) do |_env|
      [422, { content_type: 'application/json' }, valid_invalid_job_response]
    end
    pj = PrintJob.new(printables: [{ label: { test_atrr: 'test', barcode: '12345' } }], printer: @printer.name)
    assert_equal false, pj.print, 'Invalid job saved with true'
    assert_includes pj.errors.full_messages, 'Print server Printer does not exist'
  end
end
