# FMLForms

Render [FML form documents](https://docs.google.com/a/adhocteam.us/document/d/1GBfEEJ48grDz0qwK-Tjppdmpp6mDBCND0UfrA0u1WF4/edit) into other formats.

## Usage

To run the tests just run `bundle install` then `rake`

## Installation

Add this line to your application's Gemfile:

    gem 'fml_forms'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fml_forms

## Form Markup Language Spec

The Form Markup Language defines a syntax for representing a form. The intention is that a non-technical user can look at an existing digital or paper form and use this markup to create a form specification that the FML app will automatically render into a form.

The FML spec may be implemented in either YAML or JSON; what’s important are the fields, their values, and their relationships.

## 1.0 FML Elements

### 1.0.1 form

This is the root element of each document.  It has the following sub-elements:

<table>
  <tr>
    <td>Name</td>
    <td>Type</td>
    <td>Description</td>
    <td>Required</td>
  </tr>
  <tr>
    <td>title</td>
    <td>string</td>
    <td>The display title of the form. Not required to be unique</td>
    <td>yes</td>
  </tr>
  <tr>
    <td>fieldsets</td>
    <td>list of fieldsets</td>
    <td>A collection of fieldsets</td>
    <td>yes</td>
  </tr>
  <tr>
    <td>version</td>
    <td>string</td>
    <td>The form version</td>
    <td>yes</td>
  </tr>
  <tr>
    <td>id</td>
    <td>string</td>
    <td>The form’s identifier. Must be unique across all forms. Must be consistent with previous versions of the form.</td>
    <td>yes</td>
  </tr>
</table>


### 1.0.2 fieldsets

Sub-element to **form**.  Contains a list of **fieldset **elements.

### 1.0.3 fieldset

Sub-element to **fieldsets**.  Contains a list of fields.

### 1.0.4 field

Sub-element to **fieldset**.  It has the following sub-elements:

<table>
  <tr>
    <td>Name</td>
    <td>Type</td>
    <td>Description</td>
    <td>required</td>
  </tr>
  <tr>
    <td>name</td>
    <td>string</td>
    <td>The name of the field</td>
    <td>yes</td>
  </tr>
  <tr>
    <td>fieldType</td>
    <td>string</td>
    <td>The type of the field.  Can be [checkbox, string, text, number, select, multiselect, yes_no, date, time, markdown, radio].  More will be defined in the future.</td>
    <td>yes</td>
  </tr>
  <tr>
    <td>label</td>
    <td>string </td>
    <td>The label to use for the field when displaying the form</td>
    <td>yes</td>
  </tr>
  <tr>
    <td>prompt</td>
    <td>string</td>
    <td>Prompt to appear within the input field.  Only for use with field type of string</td>
    <td>no</td>
  </tr>
  <tr>
    <td>isRequired</td>
    <td>boolean</td>
    <td>Indicates if this field is required for form submission. Defaults to true</td>
    <td>no</td>
  </tr>
  <tr>
    <td>options</td>
    <td>list</td>
    <td>If the field is a select or multiselect, defines selection values</td>
    <td>no</td>
  </tr>
  <tr>
    <td>conditionalOn</td>
    <td>string</td>
    <td>The name of a yes_no or checkbox field on which the specified field depends. Will only be shown if the yes_no or checkbox field referenced is true unless the field name is prefixed with "!", in which case it will only be shown if the yes_no field is false</td>
    <td>no</td>
  </tr>
  <tr>
    <td>validations</td>
    <td>list</td>
    <td></td>
    <td>no</td>
  </tr>
  <tr>
    <td>value</td>
    <td>string</td>
    <td>The value of the filled-out form field.

If a user entered “bananas” in a text field, the value attribute of that field would be “bananas”.</td>
    <td>no</td>
  </tr>
  <tr>
    <td>helptext</td>
    <td>string</td>
    <td>Explanatory text to display to the user</td>
    <td>no</td>
  </tr>
  <tr>
    <td>format</td>
    <td>string</td>
    <td>Date field format. Uses ruby strftime syntax</td>
    <td>no</td>
  </tr>
  <tr>
    <td>disable</td>
    <td>boolean</td>
    <td>Whether this field is disabled or not</td>
    <td>no</td>
  </tr>
  <tr>
    <td>ratingCalculator</td>
    <td>string</td>
    <td>The exact label of the rating caculator field that this field maps to.</td>
    <td>no</td>
  </tr>
</table>


### 1.0.5 Validations

#### 1.0.5.1 requiredIf

A requiredIf validation asserts that the field with the validation is required if the boolean field it refers to is true. So, given this field:

 - field:

          name: "firstName"

          fieldType: "text"

          label: "First name"

          validations:

            - requiredIf: "someBooleanField"

"firstName" will only be required if “someBooleanField” is true.

requiredIf also supports negative assertions when the field name is prefixed by "!". Given this field:

 - field:

          name: "firstName"

          fieldType: "text"

          label: "First name"

          validations:

            - requiredIf: "!someBooleanField"

"firstName" will only be required if “someBooleanField” is false.

An FML processor should raise an error if "someBooleanField" is not a boolean or yes_no field in the form.

#### 1.0.5.2 minLength

A minLength validation asserts that a text field is at least a given length. Given this field:

 - field:

          name: "notes"

          fieldType: "text"

          label: "Notes"

          validations:

            - minLength: 10

"notes" will be required to be at least 10 characters in length.

### 1.0.6 Field Types

#### 1.0.6.1 Text

A multiline text field

#### 1.0.6.2 Date

A text input field. The date format defaults to MM/DD/YYYY , but the "format" parameter can change that. Formats should be specified in ruby [strftime syntax](http://apidock.com/ruby/DateTime/strftime)

#### 1.0.6.3 String

A single line input field

#### 1.0.6.4 Checkbox

A checkbox

#### 1.0.6.5 Select

A drop down list. Options should be listed as name/value pairs under the "options" key. See examples.

#### 1.0.6.6 MultiSelect

A list from which the user may choose one or more elements. Options should be listed as name/value pairs under the "options" key.

#### 1.0.6.7 Number

A text field for entering a numeric value

#### 1.0.6.7 Markdown

A field with static content to be displayed to the user, useful for notes or instructions

#### 1.0.6.8 Radio

A series of radio buttons. Options should be listed as name/value pairs under the "options" key.

## 1.1 Example YAML FML document

form:

  title: "Tell us a little about yourself"

  version: "1.0"

  id: "general_info"

  fieldsets:

    - fieldset:

      - field:

          name: "firstName"

          fieldType: "text"

          label: "First name"

          prompt: "What is your first name?"

          isRequired: true

          validations:

            - minLength: 10

      - field:

          name: "middleName"

          fieldType: "text"

          label: "Middle name"

          prompt: "Or just your middle initial"

          isRequired: false

      - field:

          name: "lastName"

          fieldType: "text"

          label: "Last name"

          isRequired: true

      - field:

          name: "address1"

          fieldType: "text"

          label: "Address"

          isRequired: true

      - field:

          name: "address2"

          fieldType: "text"

          label: "Apt or Suite"

          isRequired: false

      - field:

          name: "city"

          fieldType: "text"

          label: "City"

          isRequired: true

      - field:

          name: "state"

          fieldType: "select"

          label: "State"

          prompt: "Select one"

          isRequired: true

          options:

            - name: "Alabama"

              value: "AL"

            - name: "Alaska"

              value: "AK"

            - name: "Arizona"

              value: "AZ"

      - field:

          name: "zip"

          fieldType: "text"

          label: "Zip code"

          isRequired: true

      - field:

          name: "address_type"

          fieldType: "radio"

          label: "Address Type"

          isRequired: false

          options:

            - name: "home"

              value: "Single Family Home"

            - name: "apartment"

              value: "Apartment Building"

            - name: "condo"

              value: "Condominium"

## 1.2 Example JSON FML Document

This JSON object is equivalent to the above YAML:

{

  "form": {

    "title": ""Tell us a little about yourself"",

    "version": ""1.0"",

    "id": ""general_info"",

    "fieldsets": [

      {

        "fieldset": [

          {

            "field": {

              "name": "firstName",

              "fieldType": "text",

              "label": "First name",

              "prompt": "What is your first name?",

              "isRequired": true

            }

          },

          {

            "field": {

              "name": "middleName",

              "fieldType": "text",

              "label": "Middle name",

              "prompt": "Or just your middle initial",

              "isRequired": false

            }

          },

          {

            "field": {

              "name": "lastName",

              "fieldType": "text",

              "label": "Last name",

              "isRequired": true

            }

          },

          {

            "field": {

              "name": "address1",

              "fieldType": "text",

              "label": "Address",

              "isRequired": true

            }

          },

          {

            "field": {

              "name": "address2",

              "fieldType": "text",

              "label": "Apt or Suite",

              "isRequired": false

            }

          },

          {

            "field": {

              "name": "city",

              "fieldType": "text",

              "label": "City",

              "isRequired": true

            }

          },

          {

            "field": {

              "name": "state",

              "fieldType": "select",

              "label": "State",

              "prompt": "Select one",

              "isRequired": true,

              "options": [

                {

                  "name": "Alabama",

                  "value": "AL"

                },

                {

                  "name": "Alaska",

                  "value": "AK"

                },

                {

                  "name": "Arizona",

                  "value": "AZ"

                }

              ]

            }

          },

          {

            "field": {

              "name": "zip",

              "fieldType": "text",

              "label": "Zip code",

              "isRequired": true

            }

          }

        ]

      }

    ]

  }

}


## Deploying

To deploy to our geminabox server, you first need to increment the version of
the gem, which is in lib/fml/version.rb. Then:

    # if you don't have the source added, add it. After you've done this once,
    # you shouldn't need to do it again
    $ gem sources -a http://107.170.81.161:9292/
    $ rake deploy
