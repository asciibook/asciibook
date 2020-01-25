require 'test_helper'

class Asciibook::Converter::DlistTest < Asciibook::Test
  def test_convert_dlist
    doc = <<~EOF
      Label One:: Content one.
      Label Two:: Content two.
      Label Three:: Content three.
    EOF

    html = <<~EOF
      <dl class="dlist">
        <dt>Label One</dt>
        <dd>Content one.</dd>
        <dt>Label Two</dt>
        <dd>Content two.</dd>
        <dt>Label Three</dt>
        <dd>Content three.</dd>
      </dl>

    EOF

    assert_convert_body html, doc
  end

  def test_convert_dlist_include_list
    doc = <<~EOF
      Dairy::
      * Milk
      * Eggs
      Bakery::
      * Bread
      Produce::
      * Bananas
    EOF

    html = <<~EOF
      <dl class="dlist">
        <dt>Dairy</dt>
        <dd>
          <ul class="ulist">
            <li><p>Milk</p></li>
            <li><p>Eggs</p></li>
          </ul>
        </dd>
        <dt>Bakery</dt>
        <dd>
          <ul class="ulist">
            <li><p>Bread</p></li>
          </ul>
        </dd>
        <dt>Produce</dt>
        <dd>
          <ul class="ulist">
            <li><p>Bananas</p></li>
          </ul>
        </dd>
      </dl>
    EOF

    assert_convert_body html, doc
  end

  def test_convert_dlist_include_dlist
    doc = <<~EOF
      Operating Systems::
        Linux:::
          . Fedora
            * Desktop
          . Ubuntu
            * Desktop
            * Server
        BSD:::
          . FreeBSD
          . NetBSD

      Cloud Providers::
        PaaS:::
          . OpenShift
          . CloudBees
        IaaS:::
          . Amazon EC2
          . Rackspace
    EOF

    html = <<~EOF
      <dl class="dlist">
        <dt>Operating Systems</dt>
        <dd>
          <dl class="dlist">
            <dt>Linux</dt>
            <dd>
              <ol class="olist">
                <li>
                  <p>Fedora</p>
                  <ul class="ulist">
                    <li><p>Desktop</p></li>
                  </ul>
                </li>
                <li>
                  <p>Ubuntu</p>
                  <ul class="ulist">
                    <li><p>Desktop</p></li>
                    <li><p>Server</p></li>
                  </ul>
                </li>
              </ol>
            </dd>
            <dt>BSD</dt>
            <dd>
              <ol class="olist">
                <li>
                  <p>FreeBSD</p>
                </li>
                <li>
                  <p>NetBSD</p>
                </li>
              </ol>
            </dd>
          </dl>
        </dd>
        <dt>Cloud Providers</dt>
        <dd>
          <dl class="dlist">
            <dt>PaaS</dt>
            <dd>
              <ol class="olist">
                <li>
                  <p>OpenShift</p>
                </li>
                <li>
                  <p>CloudBees</p>
                </li>
              </ol>
            </dd>
            <dt>IaaS</dt>
            <dd>
              <ol class="olist">
                <li>
                  <p>Amazon EC2</p>
                </li>
                <li>
                  <p>Rackspace</p>
                </li>
              </ol>
            </dd>
          </dl>
        </dd>
      </dl>
    EOF

    assert_convert_body html, doc
  end
end
