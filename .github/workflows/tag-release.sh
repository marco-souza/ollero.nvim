#! /bin/bash
version=$(cat plugin.json | jq -r '.version')
echo Package version is $version

tag_version=$(git tag -l | grep $version)
echo Repo tag found: $tag_version

# exit if tag already exists
if [ -n "$tag_version" ]; then
  echo "Tag $version already exists"
  exit 0
fi

echo "Creating tag $version"
git tag $version && git push --tags

echo "Creating release $version"
gh release create -t $version --generate-notes --latest $version

