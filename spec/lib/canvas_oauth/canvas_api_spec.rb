require 'spec_helper'

describe CanvasOauth::CanvasApi do
  let(:canvas) { CanvasOauth::CanvasApi.new('http://test.canvas', 'token', 'key', 'secret') }

  describe "initializer" do
    subject { canvas }

    its(:canvas_url) { is_expected.to eq 'http://test.canvas' }
    its(:token) { is_expected.to eq 'token' }
    its(:key) { is_expected.to eq 'key' }
    its(:secret) { is_expected.to eq 'secret' }
  end

  describe "auth_url" do
    subject { canvas.auth_url('http://localhost:3001/canvas/oauth', 'zzxxyy') }

    it { is_expected.to eq "http://test.canvas/login/oauth2/auth?client_id=key&response_type=code&state=zzxxyy&redirect_uri=http://localhost:3001/canvas/oauth" }
  end

  describe "hash_csv" do
    it "accepts a csv string and hashes it" do
      csv = "canvas_course_id,course_id,short_name\n1,,Test Course"
      expect(canvas.hash_csv(csv)).to eq([{
        "canvas_course_id" => "1",
        "course_id" => "",
        "short_name" => "Test Course"
      }])
    end

    it "accepts a parsed csv array and hashes it" do
      csv = [["canvas_course_id", "course_id", "short_name"], ["1", nil, "Test Course"]]
      expect(canvas.hash_csv(csv)).to eq([{
        "canvas_course_id" => "1",
        "course_id" => "",
        "short_name" => "Test Course"
      }])
    end
  end

  describe "get_access_token" do
    it "POSTs to /login/oauth2/token" do
      expect(CanvasOauth::CanvasApi).to receive(:post).with('/login/oauth2/token', anything()).and_return({})
      canvas.get_access_token('code')
    end

    it "returns the access token" do
      allow(CanvasOauth::CanvasApi).to receive(:post).and_return({ 'access_token' => 'token' })
      expect(canvas.get_access_token('code')).to eq 'token'
    end

    it "sends the key, secret, and code as params" do
      params = {
        body: {
          client_id: 'key',
          client_secret: 'secret',
          code: 'code'
        }
      }

      expect(CanvasOauth::CanvasApi).to receive(:post).with(anything(), params).and_return({})
      canvas.get_access_token('code')
    end
  end

  describe "requests" do
    describe "authenticated_request" do
      it "passes the params along as-is and adds an Authorization header" do
        expect(CanvasOauth::CanvasApi).to receive(:get).with('/path', { query: 'stuff', headers: { 'Authorization' => 'Bearer token' } })
        canvas.authenticated_request :get, '/path', { query: 'stuff' }
      end

      it "raises an authenticate error when the response is a 401 and WWW-Authenticate is set" do
        allow(CanvasOauth::CanvasApi).to receive(:get).and_return(double(unauthorized?: true, headers: { 'WWW-Authenticate' => true }))
        expect { canvas.authenticated_request :get, '/path' }.to raise_error CanvasOauth::CanvasApi::Authenticate
      end

      it "raises an unauthorized error when the response is a 401" do
        allow(CanvasOauth::CanvasApi).to receive(:get).and_return(double(unauthorized?: true, headers: {}))
        expect { canvas.authenticated_request :get, '/path' }.to raise_error CanvasOauth::CanvasApi::Unauthorized
      end
    end

    describe "get_courses" do
      it "queries /api/v1/courses" do
        expect(CanvasOauth::CanvasApi).to receive(:get).with('/api/v1/courses', anything())
        canvas.get_courses
      end
    end

    describe "get_account_courses" do
      it "queries /api/v1/accounts/:id/courses" do
        expect(CanvasOauth::CanvasApi).to receive(:get).with('/api/v1/accounts/1/courses', anything())
        canvas.get_account_courses(1)
      end

      it "paginates" do
        expect(canvas).to receive(:paginated_get)
        canvas.get_account_courses(1)
      end
    end

    describe "get account users" do
      it "queries /api/v1/accounts/:id/users" do
        expect(CanvasOauth::CanvasApi).to receive(:get).with('/api/v1/accounts/1/users', anything())
        canvas.get_account_users(1)
      end

      it "paginates" do
        expect(canvas).to receive(:paginated_get)
        canvas.get_account_users(1)
      end
    end

    describe "get_course" do
      it "queries /api/v1/courses/:id" do
        expect(CanvasOauth::CanvasApi).to receive(:get).with('/api/v1/courses/123', anything())
        canvas.get_course('123')
      end
    end

    describe "get_course_students" do
      it "queries /api/v1/courses/:id/students" do
        expect(CanvasOauth::CanvasApi).to receive(:get).with('/api/v1/courses/123/students', anything())
        canvas.get_course_students('123')
      end

      it "paginates" do
        expect(canvas).to receive(:paginated_get)
        canvas.get_course_students('123')
      end
    end

    describe "get_sections" do
      it "queries /api/v1/courses/:id/sections" do
        expect(CanvasOauth::CanvasApi).to receive(:get).with('/api/v1/courses/123/sections', anything())
        canvas.get_sections('123')
      end

      it "paginates" do
        expect(canvas).to receive(:paginated_get)
        canvas.get_sections('123')
      end
    end

    describe "get_assignments" do
      it "queries /api/v1/courses/:id/assignments" do
        expect(CanvasOauth::CanvasApi).to receive(:get).with('/api/v1/courses/123/assignments', anything())
        canvas.get_assignments('123')
      end

      it "paginates" do
        expect(canvas).to receive(:paginated_get)
        canvas.get_account_courses('123')
      end
    end

    describe "get_user_profile" do
      it "queries /api/v1/users/:id/profile" do
        expect(CanvasOauth::CanvasApi).to receive(:get).with('/api/v1/users/123/profile', anything())
        canvas.get_user_profile('123')
      end
    end

    describe "create_assignment" do
      it "posts to /api/v1/courses/:id/assignments" do
        expect(CanvasOauth::CanvasApi).to receive(:post).with('/api/v1/courses/123/assignments', anything())
        canvas.create_assignment('123', name: "Assignment")
      end

      it "sets the body of the request to the assignment params" do
        expect(canvas).to receive(:authenticated_post).with(anything(), { body: { assignment: { name: "Assignment" }}})
        canvas.create_assignment('123', name: "Assignment")
      end
    end

    describe "update_assignment" do
      it "puts to /api/v1/courses/:course_id/assignments/:id" do
        expect(CanvasOauth::CanvasApi).to receive(:put).with('/api/v1/courses/123/assignments/345', anything())
        canvas.update_assignment('123', '345', omit_from_final_grade: true)
      end

      it "sets the body of the request to the assignment params" do
        expect(canvas).to receive(:authenticated_put).
          with(anything(), { body: { assignment: { omit_from_final_grade: true }}})

        canvas.update_assignment('123', '345', omit_from_final_grade: true)
      end
    end

    describe "grade_assignment" do
      it "puts to /api/v1/courses/:course_id/assignments/:assignment_id/submissions/:id" do
        expect(CanvasOauth::CanvasApi).to receive(:put).with('/api/v1/courses/1/assignments/2/submissions/3', anything())
        canvas.grade_assignment('1', '2', '3', {})
      end

      it "sets the body of the request to the grade params" do
        expect(canvas).to receive(:authenticated_put).with(anything(), { body: { percentage: "80%" }})
        canvas.grade_assignment('1', '2', '3', percentage: "80%")
      end
    end

    describe 'get_submission' do
      it 'queries /api/v1/courses/:course_id/assignments/:assignment_id/submissions/:user_id' do
        expect(canvas).to receive(:authenticated_get).with('/api/v1/courses/1/assignments/2/submissions/3')
        canvas.get_submission(1, 2, 3)
      end
    end

    describe "get_report" do
      context "from account level" do
        let(:created) {
          {
            'id' => '9',
            'status' => 'created'
          }
        }
        let(:complete) {
          {
            'id' => '10',
            'status' => 'complete',
            'file_url' => '/files/8/download/'
          }
        }
        let(:running) {
          {
            'id' => '11',
            'status' => 'running'
          }
        }
        let(:aborted) {
          {
            'id' => '12',
            'status' => 'aborted'
          }
        }
        let(:file) { {'url': 'http://canvas.com'} }
        let(:response) { double("response", :parsed_response => "1, 2, 3") }
        let(:params) {
          {
            account_id: '1',
            email: "foo@bar.com",
            filters: {
              start_date: '07/30/19',
              end_date: '07/31/19'
            }
          }
        }

        before(:each) do
          allow(canvas).to receive(:authenticated_post).and_return(created)
          allow(canvas).to receive(:get_file).and_return(file)
          allow(CanvasOauth::CanvasApi).to receive(:get).and_return(response)
          allow(self).to receive(:sleep)
        end

        it "posts to /api/v1/accounts/:account_id/reports/:provisioning_csv" do
          allow(canvas).to receive(:authenticated_get).and_return(complete)
          expect(canvas).to receive(:authenticated_post).with("/api/v1/accounts/1/reports/provisioning_csv", { body: params })
          canvas.get_report(1, :provisioning_csv, params)
        end

        it "queries /api/v1/accounts/:account_id/reports/:provisioning_csv/:report_id until report is 'complete'" do
          allow(canvas).to receive(:authenticated_get?) { true }
          expect(canvas).to receive(:authenticated_get).exactly(3).times.and_return(created, running, complete)
          canvas.get_report(1, :provisioning_csv, params)
        end

        it "doesn't continue request reports upon 'aborted' status" do
          allow(canvas).to receive(:authenticated_get?) { true }
          expect(canvas).to receive(:authenticated_get).exactly(3).times.and_return(created, running, aborted)
          canvas.get_report(1, :provisioning_csv, params)
        end

        it "uses the default UTF 8 parser it its get call" do
          allow(canvas).to receive(:authenticated_get).and_return(complete)
          expect(canvas).to receive(:authenticated_post).with("/api/v1/accounts/1/reports/provisioning_csv", { body: params })
          expect(CanvasOauth::CanvasApi).to receive(:get).with(file['url'], hash_including(parser: CanvasOauth::DefaultUTF8Parser)).and_return(response)
          canvas.get_report(1, :provisioning_csv, params)
        end
      end
    end
  end

  describe "pagination" do
    describe "valid_page?" do
      let(:valid_page) { double(size: 2, nil?: false, body: '[{some:json}]') }
      let(:same_page) { valid_page }
      let(:blank_page) { double(size: 0, nil?: false, body: '[]') }

      specify { expect(canvas.valid_page?(nil)).to be_falsey }
      specify { expect(canvas.valid_page?(valid_page)).to be_truthy }
      specify { expect(canvas.valid_page?(blank_page)).to be_falsey }
    end

    describe "paginated_get" do

      let(:first_response_link) { {'link' => "<https://foobar.com/some/address?taco=tuesday&per_page=50&page=2>; rel=\"next\", <https://foobar.com/some/address?taco=tuesday&per_page=50&page=2>; rel=\"last\""} }
      let(:query) { { query: { taco: 'tuesday' } } }

      it "adds per_page parameters to the request query" do
        expect(canvas).to receive(:authenticated_get).with("/some/address", query: { per_page: 50 })
        canvas.paginated_get "/some/address"
      end

      it "requests the next link" do
        allow(canvas).to receive(:valid_page?) { true }
        first_response = []
        second_response = []
        allow(first_response).to receive(:headers).and_return(first_response_link)
        allow(second_response).to receive(:headers).and_return({})
        expect(canvas).to receive(:authenticated_get).
          exactly(2).times.and_return(first_response,second_response)
        canvas.paginated_get "/some/address", query
      end

      it "requests the next link without repeating query elements" do
        query_expected = query.dup
        query_expected[:query][:per_page] = 50

        allow(canvas).to receive(:valid_page?) { true }

        first_response = []
        second_response = []
        allow(first_response).to receive(:headers).and_return(first_response_link)
        allow(second_response).to receive(:headers).and_return({})

        expect(canvas).to receive(:authenticated_get).with("/some/address", query_expected).and_return(first_response)
        expect(canvas).to receive(:authenticated_get).with('https://foobar.com/some/address?taco=tuesday&per_page=50&page=2', {query: nil}).and_return(second_response)

        canvas.paginated_get "/some/address", query
      end

      it "sends only one request when no next link is in the response Link header" do
        allow(canvas).to receive(:valid_page?) { true }
        response = [{totally: "A real fake response"}]
        allow(response).to receive(:headers).and_return({})
        expect(canvas).to receive(:authenticated_get).once.and_return(response)
        canvas.paginated_get "/some/address"
      end

      it "sends just one request when an invalid result is returned" do
        allow(canvas).to receive(:valid_page?) { false }
        response = []
        allow(response).to receive(:headers).and_return({})
        expect(canvas).to receive(:authenticated_get).once.and_return(response)
        canvas.paginated_get "/some/address"
      end
    end
  end

  describe "course_account_id" do
    it "returns the 'account_id' of a course" do
      allow(canvas).to receive(:get_course).with(1).and_return('account_id' => 3)
      expect(canvas.course_account_id(1)).to eq 3
    end
  end

  describe "hex_sis_id" do
    it "encodes the passed in ID and creates an SIS ID string" do
      expect(canvas.hex_sis_id("sis_course_id", "101")).to eq "hex:sis_course_id:313031"
    end
  end
end
