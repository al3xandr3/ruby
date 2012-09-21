#!/usr/bin/env ruby

module Markdown
  require 'rdiscount'
  require 'erb'
  extend self

  # Build the page
  @template1 = %q{
    <head>
    <style>
    body {
      font-family: "Segoe UI", Segoe, helvetica, arial;
      padding: 1em;
      color: #4c4c4c;
      padding-bottom: 42px;
    padding-top: 1em;
    margin-left: auto;
    margin-right: auto;
    width: 700px;
    position: relative;
    }
    p {
      max-width: 40em;
    }    
    h1, h2, h3, h4 {
     font-family: "Segoe UI", Segoe, helvetica, arial;
     color: #666;
    }
    h1 {
      background-color: #E5F7FD;
      border-bottom: 1px solid #B2E7FA;
      padding: .25em 1em;
      margin: 1em -1em .25em;
      color: #007DC5;
    }
    pre {
      border: 1px solid #D8D8D8;
      background-color: #F7F7F7;
      font: 1em/1.5 'andale mono','lucida console', monospace;
      overflow: auto;
      padding: 1.5em 0em 1.5em !important;
    }
    blockquote {
      border-left: 4px double #CCC;
      font-style: italic;
      padding-left: 1em;
    }
    </style>
    </head>
    <body>
      <%= content %>
      <br /> 
    </body>
    </html>
  }.gsub(/^\s+/, '')



  def html input, template=nil

    # read input
    markdown = RDiscount.new(File.read(input))
    content  = markdown.to_html
    if template nil?
      template = @template1
    else 
      template = File.read(input)
    end

    # fill template    
    page = ERB.new(template, 0, "%<>").result(binding)

    # write out
    input_dir = File.dirname input
    html_file = File.basename(input).gsub(/\.md$/, '.html')
    output = "#{input_dir}/#{html_file}"
    File.open(output, "w") do |f|
      f.write(page)
    end

    return page
  end
end

if __FILE__ == $0  

  if ARGV[0] == "html"
    Markdown.html ARGV[1], ARGV[2]
  end
  
end
