
require 'rest_client'
require 'json'

# spec:
#  http://www.openrdf.org/doc/sesame2/system/ch08.html#d0e314

# dependent on:
#  https://github.com/archiloque/rest-client
#  http://rubydoc.info/gems/rest-client/1.6.1/frames

module Sesame

    def self.sparql query, repo, options={}
      host = (options["host"] || "http://localhost:8080") + "/openrdf-sesame/repositories"
      
      # search
      if /^SELECT/i =~ query
        resp = RestClient.get "#{host}/#{repo}", { 
          :params => {:query => query},
          :accept => (options["accept"] || "application/sparql-results+json")
        }
        resp = JSON.parse(resp.to_s)
      end

      # update
      if /^INSERT/i =~ query or /^DELETE/i =~ query or /^CLEAR/i =~ query
        resp = RestClient.post "#{host}/#{repo}/statements", { 
          :update => query,
          :content_type => "application/x-www-form-urlencoded"
        }
        resp = resp.code
      end

      # export rdf/turtle
      if /^CONSTRUCT/i =~ query
        resp = RestClient.get "#{host}/#{repo}", { 
          :params => {:query => query},
          :accept => (options["accept"] || "application/x-turtle")
        }
      end

      resp
    end

    # import
    def self.add file, repo, options={}
      host = (options["host"] || "http://localhost:8080") + "/openrdf-sesame/repositories"
      r = RestClient.post "#{host}/#{repo}/statements", File.open(file).read, 
            :content_type => "application/x-turtle",
            :params => {:context => "<file://#{file}>"}
      r.code
    end

end


if __FILE__ == $0

  require "test/unit"
  class TestSesame < Test::Unit::TestCase
    
    def test_connected
      response = RestClient.get "http://localhost:8080/openrdf-sesame" + '/protocol'
      assert_equal 200, response.code, "connected"
      assert_equal "6", response.to_s, "version"
    end

    def test_query 
      r = Sesame.sparql "SELECT ?s ?p ?o where { ?s ?p ?o . }", "SYSTEM"
      assert_equal ["s", "p", "o"], r["head"]["vars"], "query"
    end

    def test_update
      Sesame.sparql "INSERT DATA { <http://example/book3> <http://purl.org/dc/elements/1.1/#title> \"A new book\" . }", "test_repo"
      r = Sesame.sparql("SELECT ?s WHERE { <http://example/book3> ?s ?o . }", "test_repo")
      assert_equal 1, r["results"]["bindings"].size, "insert"

      Sesame.sparql "DELETE WHERE { <http://example/book3> ?p ?o . }", "test_repo"
      r = Sesame.sparql("SELECT ?s WHERE { <http://example/book3> ?s ?o . }", "test_repo")
      assert_equal 0, r["results"]["bindings"].size, "delete"
    end

    def test_construct
      r = Sesame.sparql "CONSTRUCT { ?s ?p ?o } WHERE { ?s ?p ?o .}", "SYSTEM"      
      assert r.size >= 1000, "construct"
      #File.new("test.ttl", "w").puts(r)
    end

    def test_add
      assert_equal 204, Sesame.add("sesame_test.ttl", "test_repo")
      assert_equal 204, Sesame.sparql("CLEAR GRAPH <file://sesame_test.ttl>", "test_repo")
    end

  end

end

