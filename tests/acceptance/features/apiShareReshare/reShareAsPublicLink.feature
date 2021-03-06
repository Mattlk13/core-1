@api @TestAlsoOnExternalUserBackend
Feature: reshare as public link
  As a user
  I want to create public link shares from files/folders shared with me
  So that I can give controlled access to others

  Background:
    Given using old DAV path
    And user "user0" has been created with default attributes and skeleton files
    And user "user1" has been created with default attributes and without skeleton files

  @public_link_share-feature-required
  Scenario Outline: creating a public link from a share with read permission only is not allowed
    Given using OCS API version "<ocs_api_version>"
    And user "user0" has created folder "/test"
    And user "user0" has shared folder "/test" with user "user1" with permissions "read"
    When user "user1" creates a public link share using the sharing API with settings
      | path         | /test |
      | publicUpload | false |
    Then the OCS status code should be "404"
    And the HTTP status code should be "<http_status_code>"
    Examples:
      | ocs_api_version | http_status_code |
      | 1               | 200              |
      | 2               | 404              |

  @public_link_share-feature-required
  Scenario Outline: creating a public link from a share with share+read only permissions is allowed
    Given using OCS API version "<ocs_api_version>"
    And user "user0" has created folder "/test"
    And user "user0" has uploaded file with content "some content" to "/test/file.txt"
    And user "user0" has shared folder "/test" with user "user1" with permissions "share,read"
    When user "user1" creates a public link share using the sharing API with settings
      | path         | /test |
      | publicUpload | false |
    Then the OCS status code should be "<ocs_status_code>"
    And the HTTP status code should be "200"
    And the public should be able to download file "file.txt" from inside the last public shared folder and the content should be "some content"
    But publicly uploading a file should not work
    Examples:
      | ocs_api_version | ocs_status_code |
      | 1               | 100             |
      | 2               | 200             |

  @public_link_share-feature-required
  Scenario Outline: creating an upload public link from a share with share+read only permissions is not allowed
    Given using OCS API version "<ocs_api_version>"
    And user "user0" has created folder "/test"
    And user "user0" has shared folder "/test" with user "user1" with permissions "share,read"
    When user "user1" creates a public link share using the sharing API with settings
      | path         | /test                     |
      | permissions  | read,update,create,delete |
      | publicUpload | true                      |
    Then the OCS status code should be "404"
    And the HTTP status code should be "<http_status_code>"
    Examples:
      | ocs_api_version | http_status_code |
      | 1               | 200              |
      | 2               | 404              |

  @public_link_share-feature-required
  Scenario Outline: creating a public link from a share with read+write permissions only is not allowed
    Given using OCS API version "<ocs_api_version>"
    And user "user0" has created folder "/test"
    And user "user0" has shared folder "/test" with user "user1" with permissions "change"
    When user "user1" creates a public link share using the sharing API with settings
      | path         | /test |
      | publicUpload | true  |
    Then the OCS status code should be "404"
    And the HTTP status code should be "<http_status_code>"
    Examples:
      | ocs_api_version | http_status_code |
      | 1               | 200              |
      | 2               | 404              |

  @public_link_share-feature-required
  Scenario Outline: creating a public link from a share with share+read+write permissions is allowed
    Given using OCS API version "<ocs_api_version>"
    And user "user0" has created folder "/test"
    And user "user0" has uploaded file with content "some content" to "/test/file.txt"
    And user "user0" has shared folder "/test" with user "user1" with permissions "all"
    When user "user1" creates a public link share using the sharing API with settings
      | path         | /test |
      | publicUpload | false |
    Then the OCS status code should be "<ocs_status_code>"
    And the HTTP status code should be "200"
    And the public should be able to download file "file.txt" from inside the last public shared folder and the content should be "some content"
    But publicly uploading a file should not work
    Examples:
      | ocs_api_version | ocs_status_code |
      | 1               | 100             |
      | 2               | 200             |

  @public_link_share-feature-required
  Scenario Outline: creating an upload public link from a share with share+read+write permissions is allowed
    Given using OCS API version "<ocs_api_version>"
    And user "user0" has created folder "/test"
    And user "user0" has uploaded file with content "some content" to "/test/file.txt"
    And user "user0" has shared folder "/test" with user "user1" with permissions "all"
    When user "user1" creates a public link share using the sharing API with settings
      | path         | /test                     |
      | permissions  | read,update,create,delete |
      | publicUpload | true                      |
    Then the OCS status code should be "<ocs_status_code>"
    And the HTTP status code should be "200"
    And the public should be able to download file "file.txt" from inside the last public shared folder and the content should be "some content"
    And publicly uploading a file should work
    Examples:
      | ocs_api_version | ocs_status_code |
      | 1               | 100             |
      | 2               | 200             |

  @public_link_share-feature-required
  Scenario Outline: creating an upload public link from a sub-folder of a share with share+read only permissions is not allowed
    Given using OCS API version "<ocs_api_version>"
    And user "user0" has created folder "/test"
    And user "user0" has created folder "/test/sub"
    And user "user0" has shared folder "/test" with user "user1" with permissions "share,read"
    When user "user1" creates a public link share using the sharing API with settings
      | path         | /test/sub                 |
      | permissions  | read,update,create,delete |
      | publicUpload | true                      |
    Then the OCS status code should be "404"
    And the HTTP status code should be "<http_status_code>"
    Examples:
      | ocs_api_version | http_status_code |
      | 1               | 200              |
      | 2               | 404              |

  @public_link_share-feature-required
  Scenario Outline: increasing permissions of a public link of a share with share+read only permissions is not allowed
    Given using OCS API version "<ocs_api_version>"
    And user "user0" has created folder "/test"
    And user "user0" has created folder "/test/sub"
    And user "user0" has shared folder "/test" with user "user1" with permissions "share,read"
    And user "user1" has created a public link share with settings
      | path         | /test |
      | permissions  | read  |
      | publicUpload | false |
    When user "user1" updates the last share using the sharing API with
      | permissions | read,update,create,delete |
    Then the OCS status code should be "404"
    And the HTTP status code should be "<http_status_code>"
    And publicly uploading a file should not work
    Examples:
      | ocs_api_version | http_status_code |
      | 1               | 200              |
      | 2               | 404              |

  @public_link_share-feature-required
  Scenario Outline: increasing permissions of a public link from a sub-folder of a share with share+read only permissions is not allowed
    Given using OCS API version "<ocs_api_version>"
    And user "user0" has created folder "/test"
    And user "user0" has created folder "/test/sub"
    And user "user0" has shared folder "/test" with user "user1" with permissions "share,read"
    And user "user1" has created a public link share with settings
      | path         | /test/sub |
      | permissions  | read      |
      | publicUpload | false     |
    And publicly uploading a file should not work
    When user "user1" updates the last share using the sharing API with
      | permissions | read,update,create,delete |
    Then the OCS status code should be "404"
    And the HTTP status code should be "<http_status_code>"
    And publicly uploading a file should not work
    Examples:
      | ocs_api_version | http_status_code |
      | 1               | 200              |
      | 2               | 404              |
