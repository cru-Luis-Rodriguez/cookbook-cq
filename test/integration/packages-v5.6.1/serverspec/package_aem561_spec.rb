require_relative '../../../kitchen/data/spec_helper'

describe 'Slice 4.2.1' do
  it 'is uploaded' do
    expect(
      @package_helper.package_exists(
        'slice-assembly',
        '4\.2\.1',
        @package_list
      )
    ).to be true
  end

  it 'is installed' do
    expect(
      @package_helper.package_installed(
        'slice-assembly',
        '4\.2\.1',
        @package_list
      )
    ).to be true
  end
end

describe 'Slice Extension for CQ 5.6.1' do
  it 'is uploaded' do
    expect(
      @package_helper.package_exists(
        'slice-cq56-assembly',
        '2\.1\.0',
        @package_list
      )
    ).to be true
  end

  it 'is installed' do
    expect(
      @package_helper.package_installed(
        'slice-cq56-assembly',
        '2\.1\.0',
        @package_list
      )
    ).to be true
  end
end

describe 'com.adobe.granite.platform.users' do
  it 'is uploaded' do
    expect(
      @package_helper.package_exists(
        'com.adobe.granite.platform.users',
        '1\.0\.0',
        @package_list
      )
    ).to be true
  end
end

describe 'CQ Social Commons' do
  it 'is installed' do
    expect(
      @package_helper.package_installed(
        'cq-social-commons-pkg',
        '1\.2\.41',
        @package_list
      )
    ).to be true
  end
end

describe 'AEM Dash' do
  it 'is NOT uploaded' do
    expect(
      @package_helper.package_exists(
        'dash-full',
        '1\.2\.0',
        @package_list
      )
    ).to be false
  end

  it 'is NOT installed' do
    expect(
      @package_helper.package_installed(
        'dash-full',
        '1\.2\.0',
        @package_list
      )
    ).to be false
  end
end

describe 'CQ 5.6.1 Security Service Pack' do
  it 'is uploaded' do
    expect(
      @package_helper.package_exists(
        'CQ\ 5\.6\.1\ Security\ Service\ Pack',
        '1\.1',
        @package_list
      )
    ).to be true
  end

  it 'is installed' do
    expect(
      @package_helper.package_installed(
        'CQ\ 5\.6\.1\ Security\ Service\ Pack',
        '1\.1',
        @package_list
      )
    ).to be true

    expect(
      @package_helper.package_installed(
        'cq-base-service-pkg',
        '1\.0',
        @package_list
      )
    ).to be true

    expect(
      @package_helper.package_installed(
        'cq-5.6.1-hotfix-4412',
        '1\.0',
        @package_list
      )
    ).to be true

    expect(
      @package_helper.package_installed(
        'cq-social-forum-pkg',
        '1\.1\.50',
        @package_list
      )
    ).to be true

    expect(
      @package_helper.package_installed(
        'cq-social-activitystreams-pkg',
        '1\.0\.33',
        @package_list
      )
    ).to be true

    expect(
      @package_helper.package_installed(
        'cq-social-calendar-pkg',
        '1\.0\.36',
        @package_list
      )
    ).to be true
  end
end

describe 'ACS AEM Commons' do
  it 'version 1.9.6 is uploaded' do
    expect(
      @package_helper.package_exists(
        'acs-aem-commons-content',
        '1\.9\.6',
        @package_list
      )
    ).to be true
  end

  it 'version 1.9.6 is installed' do
    expect(
      @package_helper.package_installed(
        'acs-aem-commons-content',
        '1\.9\.6',
        @package_list
      )
    ).to be true
  end

  it 'version 1.10.0 is uploaded' do
    expect(
      @package_helper.package_exists(
        'acs-aem-commons-content',
        '1\.10\.0',
        @package_list
      )
    ).to be true
  end

  it 'version 1.10.0 was installed' do
    expect(
      @package_helper.package_installed(
        'acs-aem-commons-content',
        '1\.10\.0',
        @package_list
      )
    ).to be true
  end

  it 'version 1.10.2 is uploaded' do
    expect(
      @package_helper.package_exists(
        'acs-aem-commons-content',
        '1\.10\.2',
        @package_list
      )
    ).to be true
  end

  it 'version 1.10.2 is NOT installed' do
    expect(
      @package_helper.package_installed(
        'acs-aem-commons-content',
        '1\.10\.2',
        @package_list
      )
    ).to be false
  end
end
